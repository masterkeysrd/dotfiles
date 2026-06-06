local add = require('vim-pack').add

add {
    {
        src = 'echasnovski/mini.bufremove',
        module_name = 'mini.bufremove',
        opts = {
            set_vim_settings = true,
            silent = true,
        },
        on_setup = function()
            local quit_ft = {
                "qf",
                "help",
                "toggleterm",
            }

            local function close_buffer()
                local bufnr = vim.api.nvim_get_current_buf()

                if vim.tbl_contains(quit_ft, vim.bo[bufnr].filetype) then
                    vim.cmd("q")
                    return
                end

                require('mini.bufremove').delete(bufnr)
            end

            vim.keymap.set('n', '<leader>bd', close_buffer, { silent = true, desc = 'Delete buffer' })
            vim.keymap.set('n', '<C-w>', close_buffer, { noremap = true, silent = true, desc = 'Close tab' })
        end,
    }
}
