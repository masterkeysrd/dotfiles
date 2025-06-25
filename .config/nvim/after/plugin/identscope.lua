local ok, indentscope = pcall(require, "mini.indentscope")
local notify_opts = { title = "UI" }

if not ok then
    vim.notify("mini.indentscope not found", vim.log.levels.ERROR, notify_opts)
    return
end

indentscope.setup({
    symbol = "│",
    options = {
        try_as_border = true,
    },
    draw = {
        animation = indentscope.gen_animation.none(),
    },
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = {
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
        "nvimtree",
        "nvim-tree",
    },
    callback = function()
        vim.b.miniindentscope_disable = true
    end,
})
