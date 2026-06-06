local add = require('vim-pack').add

add {
    {
        src = 'stevearc/conform.nvim',
        opts = {
            format_on_save = {
                timeout_ms = 500,
                lsp_format = "fallback",
            },
            formatters_by_ft = {
                go = { 'gopls', "goimports", timeout_ms = 500, lsp_format = 'fallback' },
                javascript = { "prettierd", "prettier", stop_after_first = true, timeout_ms = 500, lsp_format = 'fallback' },
                javascriptreact = { "prettierd", "prettier", stop_after_first = true, timeout_ms = 500, lsp_format = 'fallback' },
                json = { "prettierd", "prettier", stop_after_first = true, timeout_ms = 500, lsp_format = 'fallback' },
                jsonc = { "prettierd", "prettier", stop_after_first = true, timeout_ms = 500, lsp_format = 'fallback' },
                sql = { "sql_formatter", timeout_ms = 500, lsp_format = 'fallback' },
                typescript = { "prettierd", "prettier", stop_after_first = true, timeout_ms = 500, lsp_format = 'fallback' },
                typescriptreact = { "prettierd", "prettier", stop_after_first = true, timeout_ms = 500, lsp_format = 'fallback' },
            },
        },
        on_setup = function()
            -- Use conform for gq.
            vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
        end,
    }
}
