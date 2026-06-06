local add = require('vim-pack').add

add {
    {
        src = 'nvim-mini/mini.clue',
        module_name = 'mini.clue',
        opts = function()
            local miniclue = require('mini.clue')
            return {
                triggers = {
                    -- Leader triggers
                    { mode = 'n', keys = '<Leader>' },
                    { mode = 'x', keys = '<Leader>' },

                    -- Built-in completion
                    { mode = 'i', keys = '<C-x>' },

                    -- `g` key
                    { mode = 'n', keys = 'g' },
                    { mode = 'x', keys = 'g' },

                    -- Marks
                    { mode = 'n', keys = "'" },
                    { mode = 'n', keys = '`' },
                    { mode = 'x', keys = "'" },
                    { mode = 'x', keys = '`' },

                    -- Registers
                    { mode = 'n', keys = '"' },
                    { mode = 'x', keys = '"' },
                    { mode = 'i', keys = '<C-r>' },
                    { mode = 'c', keys = '<C-r>' },

                    -- `z` key
                    { mode = 'n', keys = 'z' },
                    { mode = 'x', keys = 'z' },
                },

                clues = {
                    -- Enhance this by adding descriptions for <Leader> mapping groups
                    miniclue.gen_clues.builtin_completion(),
                    miniclue.gen_clues.g(),
                    miniclue.gen_clues.marks(),
                    miniclue.gen_clues.registers(),
                    miniclue.gen_clues.z(),
                    { mode = 'n', keys = '<leader>b', desc = '+buffers' },
                    { mode = 'x', keys = '<leader>b', desc = '+buffers' },
                    { mode = 'n', keys = '<leader>g', desc = '+git' },
                    { mode = 'x', keys = '<leader>g', desc = '+git' },
                    { mode = 'n', keys = '<leader>p', desc = '+project' },
                    { mode = 'x', keys = '<leader>p', desc = '+project' },
                },
                window = {
                    delay = 500,
                    scroll_down = '<C-f>',
                    scroll_up = '<C-b>',
                    config = function(bufnr)
                        local max_width = 0
                        for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)) do
                            max_width = math.max(max_width, vim.fn.strchars(line))
                        end

                        -- Keep some right padding.
                        max_width = max_width + 2

                        return {
                            -- Dynamic width capped at 70.
                            width = math.min(70, max_width),
                        }
                    end,
                },
            }
        end,
    }
}
