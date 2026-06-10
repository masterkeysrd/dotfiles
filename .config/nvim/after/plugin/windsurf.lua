local add = require('vim-pack').add

local codeium_enabled = tostring(vim.fn.getenv("CODEIUM_ENABLED"))
if codeium_enabled and codeium_enabled:upper() == "TRUE" then
    add {
        {
            src = "Exafunction/windsurf.vim",
            setup = false,
            on_setup = function()
                vim.keymap.set('i', '<C-j>', '<Plug>(codeium-next)', { noremap = false })
                vim.keymap.set('i', '<C-k>', '<Plug>(codeium-previous)', { noremap = false })
                vim.keymap.set('i', '<S-Tab>', '<Plug>(codeium-accept-line)', { noremap = false })
                vim.keymap.set('i', '<C-y>', '<Plug>(codeium-accept)', { noremap = false })
            end
        }
    }
end
