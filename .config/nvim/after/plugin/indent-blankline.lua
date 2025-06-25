local ok, ibl = pcall(require, "ibl")
local notify_opts = { title = "UI" }

if not ok then
    vim.notify("indent_blankline.nvim not found", vim.log.levels.ERROR, notify_opts)
    return
end

ibl.setup({
    indent = {
        char = "│",
        tab_char = "│",
    },
    scope = { enabled = false },
    exclude = {
        buftypes = {
            'terminal',
            'nofile',
        },
        filetypes = {
            "help",
            "alpha",
            "dashboard",
            "neo-tree",
            "Trouble",
            "trouble",
            "lazy",
            "mason",
            "notify",
            "toggleterm",
            "lazyterm",
            "NvimTree",
        },
    },
})
