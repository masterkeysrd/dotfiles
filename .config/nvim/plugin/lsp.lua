local symbol_kinds = require("masterkeysrd.icons").symbol_kinds
local methods = vim.lsp.protocol.Methods
local completion_kind = vim.lsp.protocol.CompletionItemKind

-- Disable inlay hints initially (and enable if needed with my ToggleInlayHints command).
vim.g.inlay_hints = false

--- Create the LSP Auto command group
local lspgroup = vim.api.nvim_create_augroup("lsp", { clear = true })

--- LSP on_init handler
---@param client vim.lsp.Client
local function on_init(client, result)
        if client:supports_method("textDocument/signatureHelp") then
                client.server_capabilities.signatureHelpProvider = {
                        triggerCharacters = {}
                }
        end

        if result.offsetEncoding then
                client.offset_encoding = result.offsetEncoding
        end
end


--- Completion item convert
---@param item lsp.CompletionItem
local function convert_completion_item(item)
        local abbr = symbol_kinds[item.kind] or ""
        if abbr ~= "" then
                abbr = abbr .. "  "
        end
        abbr = abbr .. item.label:gsub("%b()", "")

        local menu = ""
        if item.kind == completion_kind.Snippet then
                menu = item.detail or "Snippet"
        end

        return { abbr = abbr, kind = "", menu = menu }
end

--- Show documentation floating windows.
---@param event vim.v.event
local function show_documentation_floating_win(event)
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

--- Sets up LSP keymaps and autocommands for the given buffer.
---@param client vim.lsp.Client
---@param bufnr integer
local function on_attach(client, bufnr)
        ---@param mode string|string[]
        ---@param lhs string
        ---@param rhs string|function
        ---@param desc string
        local function keymap(mode, lhs, rhs, desc)
                vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        ---@param key string
        local function feedkeys(key)
                return vim.api.nvim_replace_termcodes(key, true, true, true)
        end

        ---@param event any
        ---@param desc string
        --- @param callback? string|(fun(args: vim.api.keyset.create_autocmd.callback_args): boolean?)
        local function create_autocmd(event, desc, callback)
                vim.api.nvim_create_autocmd(event, {
                        group = lspgroup,
                        buffer = bufnr,
                        desc = desc,
                        callback = callback

                })
        end

        -- Setup the LSP Client name on the current buffer
        vim.b[bufnr].lsp = client.name

        if client:supports_method(methods.textDocument_codeAction) then
                keymap("n", "gra", vim.lsp.buf.code_action, "LSP Code action")
                keymap("n", "<F4>", vim.lsp.buf.code_action, "LSP Code action")
        end

        if client:supports_method(methods.textDocument_completion) then
                vim.lsp.completion.enable(true, client.id, bufnr, {
                        autotrigger = true,
                        convert     = convert_completion_item
                })

                keymap("i", "<C-Space>", vim.lsp.completion.get, "LSP Completion")
                vim.keymap.set("i", "<CR>", function()
                        local key = "<CR>"
                        if vim.fn.pumvisible() == 1 then
                                key = "<C-y>"
                        end

                        return feedkeys(key)
                end, { expr = true, noremap = true, buffer = bufnr })
        end

        if client:supports_method(methods.textDocument_foldingRange) then
                local win = vim.api.nvim_get_current_win()
                vim.wo[win][0].foldmethod = "expr"
                vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
        end

        if client:supports_method(methods.textDocument_signatureHelp) then
                keymap("i", "<C-k>", vim.lsp.buf.signature_help, "Signature help")
        end

        if client:supports_method(methods.textDocument_documentHighlight) then
                create_autocmd(
                        { "CursorHold", "CursorHoldI", "InsertLeave" },
                        "Add LSP document highligth",
                        vim.lsp.buf.document_highlight
                )
                create_autocmd(
                        { "CursorMoved", "InsertEnter" },
                        "Add LSP document highligth",
                        vim.lsp.buf.clear_references
                )
        end


        if client:supports_method(methods.textDocument_inlayHint) and vim.g.inlay_hints then
                -- Initial inlay hint display.
                -- Idk why but without the delay inlay hints aren't displayed at the very start.
                vim.defer_fn(function()
                        local mode = vim.api.nvim_get_mode().mode
                        vim.lsp.inlay_hint.enable(mode == "n" or mode == "v", { bufnr = bufnr })
                end, 500)

                create_autocmd("InsertEnter", "Enable inlay hints", function()
                        if vim.g.inlay_hints then
                                vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
                        end
                end)

                create_autocmd("InsertLeave", "Disable inlay hints", function()
                        if vim.g.inlay_hints then
                                vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                        end
                end)
        end


        if client:supports_method(methods.textDocument_codeLens) then
                vim.defer_fn(function()
                        vim.lsp.codelens.refresh({ bufnr = bufnr })
                end, 500)

                vim.api.nvim_create_autocmd("LspProgress", {
                        group = lspgroup,
                        desc = "Refresh LSP codelens",
                        callback = function(ev)
                                if ev.buf == bufnr then
                                        vim.lsp.codelens.refresh({ bufnr = bufnr })
                                end
                        end,
                })

                create_autocmd({ "BufEnter", "TextChanged", "InsertLeave" }, "Refresh LSP codelens",
                        function()
                                vim.lsp.codelens.refresh({ bufnr = bufnr })
                        end
                )


                keymap("n", "gl", vim.lsp.codelens.run, "Run codelens")
        end

        if client:supports_method(methods.textDocument_formatting) then
                create_autocmd("BufWritePre", "Auto format file", function()
                        local autoformat = client.settings and client.settings.autoformat
                            or vim.b.lsp and vim.b.lsp.autoformat
                            or vim.g.lsp and vim.g.lsp.autoformat
                            or false

                        if autoformat then
                                vim.lsp.buf.format({ bufnr = bufnr, id = client.id })
                        end
                end)

                keymap("n", "<F3>", function()
                        vim.lsp.buf.format({ bufnr = bufnr, id = client.id })
                end, "Format file")
        end

        create_autocmd("CompleteChanged", "Auto format file", function()
                local event = vim.deepcopy(vim.v.event)
                show_documentation_floating_win(event)
        end)

        if client:supports_method(methods.textDocument_definition) then
                keymap("n", "gd", vim.lsp.buf.definition, "Go to definition")
        end

        if client:supports_method(methods.textDocument_declaration) then
                keymap("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
        end

        if client:supports_method(methods.textDocument_implementation) then
                keymap("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
        end

        if client:supports_method(methods.textDocument_documentSymbol) then
                keymap("n", "go", vim.lsp.buf.type_definition, "Go to symbol definition")
        end

        if client:supports_method(methods.textDocument_references) then
                keymap("n", "gr", vim.lsp.buf.references, "Go to references")
        end

        if client:supports_method(methods.textDocument_rename) then
                keymap("n", "<F2>", vim.lsp.buf.rename, "Resymbol")
        end
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

-- Update mappings when registering dynamic capabilities.
local register_capability = vim.lsp.handlers[methods.client_registerCapability]
vim.lsp.handlers[methods.client_registerCapability] = function(err, res, ctx)
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        if not client then
                return
        end

        on_attach(client, vim.api.nvim_get_current_buf())

        return register_capability(err, res, ctx)
end


vim.api.nvim_create_autocmd("LspAttach", {
        group = lspgroup,
        callback = function(args)
                local buf = args.buf
                local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

                if not client then
                        return
                end

                on_attach(client, buf)
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
