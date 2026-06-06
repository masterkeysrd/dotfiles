local add = require('vim-pack').add

add {
    {
        src = 'echasnovski/mini.indentscope',
        module_name = 'mini.indentscope',
        opts = function()
            local indentscope = require('mini.indentscope')
            return {
                symbol = "│",
                options = {
                    try_as_border = true,
                },
                draw = {
                    animation = indentscope.gen_animation.none(),
                },
            }
        end,
        on_setup = function()
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
        end,
    }
}
