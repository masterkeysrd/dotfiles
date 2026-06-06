local add = require('vim-pack').add

local copilot_enabled = tostring(vim.fn.getenv("COPILOT_ENABLED"))
if copilot_enabled and copilot_enabled:upper() == "TRUE" then
    add {
        {
            src = "github/copilot.vim",
            setup = false,
            on_setup = function()
                vim.g.copilot_no_tab_map = false

                vim.keymap.set('i', '<C-j>', '<Plug>(copilot-next)', { noremap = false })
                vim.keymap.set('i', '<C-k>', '<Plug>(copilot-previous)', { noremap = false })
                vim.keymap.set('i', '<S-Tab>', '<Plug>(copilot-accept-line)', { noremap = false })
                vim.keymap.set('i', '<C-y>', '<Plug>(copilot-accept)', { noremap = false })
            end
        }
    }
end
