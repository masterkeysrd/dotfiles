vim.pack.add({
    "https://github.com/nvim-treesitter/nvim-treesitter",
    "https://github.com/nvim-tree/nvim-web-devicons",
    "https://github.com/folke/noice.nvim",
    "https://github.com/MunifTanjim/nui.nvim",
    "https://github.com/nvim-tree/nvim-tree.lua",
    "https://github.com/lewis6991/gitsigns.nvim",
    "https://github.com/lukas-reineke/indent-blankline.nvim",
    "https://github.com/echasnovski/mini.indentscope",
    "https://github.com/ibhagwan/fzf-lua",
    "https://github.com/echasnovski/mini.surround",
    "https://github.com/echasnovski/mini.pairs",
    "https://github.com/echasnovski/mini.bufremove",
    "https://github.com/b0o/SchemaStore.nvim",
    "https://github.com/nvim-mini/mini.clue",
    "https://github.com/stevearc/conform.nvim",
    "https://github.com/windwp/nvim-ts-autotag",
})

local copilot_enabled = tostring(vim.fn.getenv("COPILOT_ENABLED"))
if copilot_enabled and copilot_enabled:upper() == "TRUE" then
    vim.pack.add({
        "https://github.com/github/copilot.vim.git"
    })
end
