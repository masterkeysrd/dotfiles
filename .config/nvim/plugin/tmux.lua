local temux_navigate = require('masterkeysrd.tmux.navigate')
local temux_resize = require('masterkeysrd.tmux.resize')

local keymap = vim.keymap.set

local function opts(desc)
  return { noremap = true, silent = true, desc = desc }
end

temux_navigate.setup({
  on_attach = function()
    keymap('n', '<C-h>', temux_navigate.left, opts('Navigate left (tmux aware)'))
    keymap('n', '<C-j>', temux_navigate.down, opts('Navigate down (tmux aware)'))
    keymap('n', '<C-k>', temux_navigate.up, opts('Navigate up (tmux aware)'))
    keymap('n', '<C-l>', temux_navigate.right, opts('Navigate right (tmux aware)'))
  end
})

temux_resize.setup({
  on_attach = function()
    keymap('n', '<C-S-Left>', temux_resize.left, opts('Resize split left (tmux aware)'))
    keymap('n', '<C-S-Down>', temux_resize.down, opts('Resize split down (tmux aware)'))
    keymap('n', '<C-S-Up>', temux_resize.up, opts('Resize split up (tmux aware)'))
    keymap('n', '<C-S-Right>', temux_resize.right, opts('Resize split right (tmux aware)'))
  end
})
