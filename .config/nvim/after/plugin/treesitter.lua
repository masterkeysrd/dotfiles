require('nvim-treesitter').setup({
    modules = {},
    ensure_installed = { 'lua', 'go' },
    ignore_install = {},
    auto_install = true,
    sync_install = false,
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = false,
            node_decremental = "<bs>",
        },
    },

})
