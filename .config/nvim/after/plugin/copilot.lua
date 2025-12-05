vim.g.copilot_no_tab_map = false

vim.keymap.set('i', '<C-j>', '<Plug>(copilot-next)', { noremap = false })
vim.keymap.set('i', '<C-k>', '<Plug>(copilot-previous)', { noremap = false })
vim.keymap.set('i', '<S-Tab>', '<Plug>(copilot-accept-line)', { noremap = false })
vim.keymap.set('i', '<C-y>', '<Plug>(copilot-accept)', { noremap = false })
