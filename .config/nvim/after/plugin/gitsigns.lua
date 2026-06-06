local add = require('vim-pack').add
local icons = require('masterkeysrd.icons')

add {
    {
        src = 'lewis6991/gitsigns.nvim',
        opts = function()
            return {
                signs = {
                    add = { text = icons.misc.vertical_bar },
                    change = { text = icons.misc.vertical_bar },
                    delete = { text = icons.misc.right_arrow },
                    topdelete = { text = icons.misc.right_arrow },
                    changedelete = { text = icons.misc.vertical_bar },
                    untracked = { text = icons.misc.vertical_bar },
                },
                signs_staged = {
                    add = { text = icons.misc.vertical_bar },
                    change = { text = icons.misc.vertical_bar },
                    delete = { text = icons.misc.right_arrow },
                    topdelete = { text = icons.misc.right_arrow },
                    changedelete = { text = icons.misc.vertical_bar },
                    untracked = { text = icons.misc.vertical_bar },
                },
                worktrees = {
                    {
                        toplevel = vim.env.HOME,
                        gitdir = vim.env.HOME .. '/.dotfiles'
                    }
                },
                on_attach = function(bufnr)
                    local gs = require('gitsigns')
                    vim.api.nvim_buf_set_var(bufnr, 'gitsigns_status_dict', {})
                    local function opts(desc)
                        return { desc = desc, buffer = bufnr }
                    end

                    local map = vim.keymap.set

                    map('n', '[g', gs.prev_hunk, opts('Previous hunk'))
                    map('n', ']g', gs.next_hunk, opts('Next hunk'))

                    map('n', '<leader>gb', gs.toggle_current_line_blame, opts "Toggle blame")
                    map('n', '<leader>gp', gs.preview_hunk, opts "Preview hunk")
                    map('n', '<leader>gr', gs.reset_hunk, opts "Reset hunk")
                    map('n', '<leader>gR', gs.reset_buffer, opts "Reset buffer")
                    map('n', '<leader>gs', gs.stage_hunk, opts "Reset buffer")
                end,
            }
        end
    }
}
