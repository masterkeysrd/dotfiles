vim.g.copilot_no_tab_map = false

vim.keymap.set('i', '<C-j>', '<Plug>(copilot-next)', { noremap = false })
vim.keymap.set('i', '<C-k>', '<Plug>(copilot-previous)', { noremap = false })
vim.keymap.set('i', '<S-CR>', '<Plug>(copilot-accept-line)', { noremap = false })
