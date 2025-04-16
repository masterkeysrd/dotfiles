local cmp_kinds = {
	'', --- [1] Text
	'', --- [2] Method
	'', --- [3] Function
	'', --- [4] Constructor
	'', --- [5] Field
	'', --- [6] Variable
	'', --- [7] Class
	'', --- [8] Interface
	'', --- [9] Module
	'', --- [10] Property
	'', --- [11] Unit
	'', --- [12] Value
	'', --- [13] Enum
	'', --- [14] Keyword
	'', --- [15] Snippet
	'', --- [16] Color
	'', --- [17] File
	'', --- [18] Reference
	'', --- [19] Folder
	'', --- [20] EnumMember
	'', --- [21] Constant
	'', --- [22] Struct
	'', --- [23] Event
	'', --- [24] Operator
	'', --- [25] TypeParameter
}

--- Completion methods
local methods = vim.lsp.protocol.Methods

--- Completions Kinds
local kinds = vim.lsp.protocol.CompletionItemKind

-- LSP on_init handler
local function on_init(client, result)
	if client.supports_method("textDocument/signatureHelp") then
		client.server_capabilities.signatureHelpProvider = {
			triggerCharacters = {}
		}
	end

	if result.offsetEncoding then
		client.offset_encoding = result.offsetEncoding
	end
end


---Setup the completion for LSP Client
---
---@param client_id integer Client ID
---@param bufnr integer Buffer Number
local function setup_completion(client_id, bufnr)
	vim.lsp.completion.enable(true, client_id, bufnr, {
		autotrigger = true,
		convert     = function(item)
			local abbr = cmp_kinds[item.kind] or ""
			if abbr ~= "" then
				abbr = abbr .. "  "
			end
			abbr = abbr .. item.label:gsub("%b()", "")

			local menu = ""
			if item.kind == kinds.Snippet then
				menu = item.detail or "Snippet"
			end

			return { abbr = abbr, kind = "", menu = menu }
		end,
	})

	vim.keymap.set("i", "<C-Space>", vim.lsp.completion.get, { noremap = true, silent = true, buffer = bufnr })
	vim.keymap.set("i", "<CR>", function()
		if vim.fn.pumvisible() == 1 then
			return vim.api.nvim_replace_termcodes("<C-y>", true, true, true) -- confirm selection
		else
			return vim.api.nvim_replace_termcodes("<CR>", true, true, true) -- normal new line
		end
	end, { expr = true, noremap = true, buffer = bufnr })
end

---Setup Mappings
local function setup_mappings()
end

local function auto_configure()
	local configs = {}
	for _, path in ipairs(vim.api.nvim_get_runtime_file("lsp/*.lua", true)) do
		local name = vim.fn.fnamemodify(path, ":t:r") -- get filename
		configs[name] = true
	end

	local enable_list = {}
	for name, _ in pairs(configs) do
		table.insert(enable_list, name)
	end

	vim.lsp.enable(enable_list, true)
end


local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.semanticTokens.multilineTokenSupport = false


vim.lsp.config("*", {
	capabilities = capabilities,
	root_markers = { ".git" },
	on_init = on_init,
})

local lspgroup = vim.api.nvim_create_augroup("lsp", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
	group = lspgroup,
	callback = function(args)
		local buf = args.buf
		local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
		-- client.server_capabilities.semanticTokensProvider = nil

		vim.b[buf].lsp = client.name

		if client:supports_method(methods.textDocument_completion) then
			setup_completion(client.id, buf)
		end

		local function opts(desc)
			return { noremap = true, silent = true, buffer = args.buf, desc = desc }
		end

		if client:supports_method(methods.textDocument_foldingRange) then
			local win = vim.api.nvim_get_current_win()
			vim.wo[win][0].foldmethod = "expr"
			vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
		end

		if client:supports_method(methods.textDocument_inlayHint) then
			-- Keymap to toogle inlay hints
			vim.keymap.set("n", "grh", function()
				vim.lsp.inlay_hint.enable(
					not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }),
					{ bufnr = buf }
				)
			end, opts("Toggle inlay hints"))
		end

		if client:supports_method(methods.textDocument_documentHighlight) then
			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI", "InsertLeave" }, {
				group = lspgroup,
				buffer = buf,
				desc = "Add LSP document highligth",
				callback = vim.lsp.buf.document_highlight
			})
			vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter" }, {
				group = lspgroup,
				buffer = args.buf,
				desc = "Unset LSP document highlight",
				callback = vim.lsp.buf.clear_references
			})
		end


		if client:supports_method(methods.textDocument_codeLens) then
			vim.api.nvim_create_autocmd("LspProgress", {
				group = lspgroup,
				desc = "Refresh LSP codelens",
				callback = function(ev)
					if ev.buf == buf then
						vim.lsp.codelens.refresh({ bufnr = buf })
					end
				end,
			})

			vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "InsertLeave" }, {
				group = lspgroup,
				buffer = args.buf,
				desc = "Refresh LSP codelens",
				callback = function()
					vim.lsp.codelens.refresh({ bufnr = buf })
				end
			})


			vim.lsp.codelens.refresh({ bufnr = args.buf })
			vim.keymap.set("n", "gl", vim.lsp.codelens.run, opts("Run codelens"))
		end

		if client:supports_method(methods.textDocument_formatting) then
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = lspgroup,
				buffer = args.buf,
				desc = "Auto format file",
				callback = function()
					local autoformat = client.settings and client.settings.autoformat
					    or vim.b.lsp and vim.b.lsp.autoformat
					    or vim.g.lsp and vim.g.lsp.autoformat
					    or false

					if autoformat then
						vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
					end
				end
			})
			vim.keymap.set("n", "<F3>", function()
				vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
			end, opts("Format file"))
		end

		vim.api.nvim_create_autocmd("CompleteChanged", {
			group = lspgroup,
			buffer = args.buf,
			desc = "Auto format file",
			callback = function()
				local event = vim.deepcopy(vim.v.event)

				if not (event and event.completed_item) then
					return
				end

				local completion = event.completed_item.user_data
				if not (completion and completion.nvim) then
					return
				end

				local lsp_comp = completion.nvim.lsp
				if not (lsp_comp and lsp_comp.completion_item) then
					return
				end

				local documentation = lsp_comp.completion_item.documentation
				if not documentation then
					return
				end

				local contents = {}
				local kind = (type(documentation) == "table" and documentation.kind) or "markdown"

				if lsp_comp.completion_item.detail and lsp_comp.completion_item.detail ~= "" then
					local details = lsp_comp.completion_item.detail
					if kind == "markdown" then
						details = "`" .. details .. "`"
					end
					table.insert(contents, details .. "\n\n")
				end

				if type(documentation) == "string" then
					table.insert(contents, documentation)
				elseif type(documentation) == "table" and documentation.value then
					vim.list_extend(
						contents,
						vim.split(documentation.value, "\n", { trimempty = true })
					)
				end

				if #contents == 0 then
					return
				end

				local offset_text = event.completed_item.word
				vim.schedule(function()
					vim.lsp.util.open_floating_preview(contents, kind, {
						title = "Documentation",
						max_width = vim.g.lsp.previewwidth or 100,
						offset_x = event.width - #offset_text + 1,
						close_events = { "CompleteChanged", "CompleteDone", "InsertLeave" },
					})
				end)
			end
		})

		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts("Go to definition"))
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts("Go to declaration"))
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts("Go to implementation"))
		vim.keymap.set("n", "go", vim.lsp.buf.type_definition, opts("Go to symbol definition"))
		vim.keymap.set("n", "gr", vim.lsp.buf.references, opts("Go to references"))
		vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts("Signature help"))
		vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, opts("Rename symbol"))
		vim.keymap.set("n", "<F4>", vim.lsp.buf.code_action, opts("Select a code action"))

		setup_mappings()
	end,
})

vim.api.nvim_create_autocmd("LSPDetach", {
	group = lspgroup,
	callback = function(arg)
		local buf = arg.buf
		vim.b[buf].lsp = nil
		vim.api.nvim_clear_autocmds({ group = lspgroup, buffer = buf })
	end,
})

-- LspProgress to redraw status
vim.api.nvim_create_autocmd("LspProgress", {
	pattern = "*",
	callback = function()
		vim.cmd("redrawstatus")
	end,
})

-- Enable function
local function enable()
	vim.g.lsp = vim.g.lsp or {}
	vim.g.lsp.autostart = true
	vim.cmd("doautoall <nomodeline> FileType")
end

-- Disable function
local function disable()
	vim.g.lsp = vim.g.lsp or {}
	vim.g.lsp.autostart = false
	vim.lsp.stop_client(vim.lsp.get_clients())
end

-- User commands
vim.api.nvim_create_user_command("LspStart", enable, {})
vim.api.nvim_create_user_command("LspStop", disable, {})



auto_configure()
