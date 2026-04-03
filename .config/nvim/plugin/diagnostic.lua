local icons = require("masterkeysrd.icons")

vim.diagnostic.config({
    status = {
        format = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.HINT] = " ",
            [vim.diagnostic.severity.INFO] = " ",
        },
    },
    virtual_lines = {
        enable = true,
        current_line = true
    },
    float = {
        border = "double",
        prefix = function(diag)
            local level = vim.diagnostic.severity[diag.severity]
            local prefix = string.format(' %s ', icons.diagnostics[level])
            return prefix, 'Diagnostic' .. level:gsub("^%l", string.upper)
        end
    },
    jump = {
        wrap = false
    },
})
