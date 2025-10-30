local symbol_kinds = require("masterkeysrd.icons").symbol_kinds
local methods = vim.lsp.protocol.Methods

-- Disable inlay hints initially (and enable if needed with my ToggleInlayHints command).
vim.g.inlay_hints = false

local function toggle_inlay_hints()
    vim.g.inlay_hints = not vim.g.inlay_hints
    vim.notify(string.format('%s inlay hints...', vim.g.inlay_hints and 'Enabling' or 'Disabling'), vim.log.levels.INFO)

    local mode = vim.api.nvim_get_mode().mode
    vim.lsp.inlay_hint.enable(vim.g.inlay_hints and (mode == 'n' or mode == 'v'))
end

vim.api.nvim_create_user_command('ToggleInlayHints', toggle_inlay_hints, { desc = 'Toggle inlay hints', nargs = 0 })

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


local completion_names = {
    "Text",          --- [1] Text
    "Method",        --- [2] Method
    "Function",      --- [3] Function
    "Constructor",   --- [4] Constructor
    "Field",         --- [5] Field
    "Variable",      --- [6] Variable
    "Class",         --- [7] Class
    "Interface",     --- [8] Interface
    "Module",        --- [9] Module
    "Propery",       --- [10] Property
    "Unit",          --- [11] Unit
    "Value",         --- [12] Value
    "Enum",          --- [13] Enum
    "Keyword",       --- [14] Keyword
    "Snippet",       --- [15] Snippet
    "Color",         --- [16] Color
    "File",          --- [17] File
    "Reference",     --- [18] Reference
    "Folder",        --- [19] Folder
    "EnumMember",    --- [20] EnumMember
    "Constant",      --- [21] Constant
    "Struct",        --- [22] Struct
    "Event",         --- [23] Event
    "Operator",      --- [24] Operator
    "TypeParameter", --- [25] TypeParameter
}

--- Completion item convert
---@param item lsp.CompletionItem
---@return lsp.CompletionItem
local function convert_completion_item(item)
    local kind_name = completion_names[item.kind] or "Text"
    local kind_icon = symbol_kinds[kind_name] or ""

    local abbr = ""
    if kind_icon ~= "" then
        abbr = kind_icon .. " "
    end

    -- Add the label, removing any parentheses
    local label = item.label:gsub("%b()", "")
    local hl_group = "CmpItemKind" .. kind_name

    return {
        abbr = abbr,
        kind = "",
        menu = label,
        abbr_hlgroup = hl_group,
        documentation = item.documentation,
    }
end

--- Show documentation floating windows.
---@param event vim.v.event
local function show_documentation_floating_win(event)
    vim.inspect(event)
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
        local details = lsp_comp.completion_item.detail or ""
        if kind == "markdown" then
            -- Sometimes scape chars come bad formated so normalize.
            details:gsub("\\\\[", "[")

            -- Format the markdown text.
            details = "```" .. vim.bo.filetype .. "\n" ..
                details .. "\n" ..
                "```"
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
    local offset_x = event.width - #offset_text + 1
    local win_width = vim.api.nvim_win_get_width(0)
    local max_width = win_width - offset_x - 2        -- subtract a small padding
    max_width = math.max(20, math.min(max_width, 80)) -- restrict the size

    vim.schedule(function()
        vim.lsp.util.open_floating_preview(contents, kind, {
            title = "Documentation",
            max_width = vim.g.lsp.previewwidth or max_width or 60,
            offset_x = offset_x,
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
        require('masterkeysrd.lightbulb').attach_lightbulb(bufnr, client.id)
    end

    if client:supports_method(methods.textDocument_documentColor, bufnr) then
        -- Nvim still do not release this feature but will be great to have when they
        -- do it.
        if vim.lsp.document_color then
            vim.lsp.document_color.enable()
        end
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


    if client:supports_method(methods.textDocument_inlayHint) then
        keymap("n", "gh", toggle_inlay_hints, "Toggle inlay hints")

        if vim.g.inlay_hints then
            -- Initial inlay hint display.
            -- Idk why but without the delay inlay hints aren't displayed at the very start.
            vim.defer_fn(function()
                local mode = vim.api.nvim_get_mode().mode
                vim.lsp.inlay_hint.enable(mode == "n" or mode == "v", { bufnr = bufnr })
            end, 500)
        end

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

    -- Add "Fix all" command for linters.
    if client.name == 'eslint' or client.name == 'stylelint_lsp' then
        vim.keymap.set('n', '<leader>cl', function()
            if not client then
                return
            end

            client:request('workspace/executeCommand', {
                command = client.name == 'eslint' and 'eslint.applyAllFixes' or 'stylelint.applyAutoFixes',
                arguments = {
                    {
                        uri = vim.uri_from_bufnr(bufnr),
                        version = vim.lsp.util.buf_versions[bufnr],
                    },
                },
            }, nil, bufnr)
        end, {
            desc = string.format('Fix all %s errors', client.name == 'eslint' and 'ESLint' or 'Stylelint'),
            buffer = bufnr,
        })
    end
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


local hover = vim.lsp.buf.hover
---@diagnostic disable-next-line: duplicate-set-field
vim.lsp.buf.hover = function()
    return hover {
        max_height = math.floor(vim.o.lines * 0.5),
        max_width = math.floor(vim.o.columns * 0.4),
    }
end

local signature_help = vim.lsp.buf.signature_help
---@diagnostic disable-next-line: duplicate-set-field
vim.lsp.buf.signature_help = function()
    return signature_help {
        max_height = math.floor(vim.o.lines * 0.5),
        max_width = math.floor(vim.o.columns * 0.4),
    }
end

vim.api.nvim_create_autocmd("LspAttach", {
    group = lspgroup,
    desc = "Configure LSP Keymaps",
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

-- Set up LSP servers.
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
    once = true,
    callback = function()
        local server_configs = vim.iter(vim.api.nvim_get_runtime_file('lsp/*.lua', true))
            :map(function(file)
                return vim.fn.fnamemodify(file, ':t:r')
            end)
            :totable()
        vim.lsp.enable(server_configs)
    end,
})
