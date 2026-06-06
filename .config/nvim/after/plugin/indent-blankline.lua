local add = require('vim-pack').add

add {
    {
        src = 'lukas-reineke/indent-blankline.nvim',
        module_name = 'ibl',
        opts = {
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
        },
    }
}
