local fzf = require("fzf-lua")
local icons = require("masterkeysrd.icons")

fzf.setup({
    { 'border-fused', 'hide' },
    fzf_colors = {
        bg = { 'bg', 'Normal' },
        gutter = { 'bg', 'Normal' },
        info = { 'fg', 'Conditional' },
        scrollbar = { 'bg', 'Normal' },
        separator = { 'fg', 'Comment' },
    },
    fzf_opts = {
        ['--info'] = 'default',
        ['--layout'] = 'reverse-list',
    },
    winopts = {
        height = 0.8,
        width = 0.70,
        preview = {
            scrollbar = true,
            layout = 'vertical',
            vertical = 'up:40%',
        },
    },
    defaults = { git_icons = false },
    previewers = {
        codeaction = { toggle_behavior = 'extend' },
    },
    lsp = {
        symbols = {
            symbol_icons = icons.symbol_kinds,
        },
        code_actions = {
            winopts = {
                width = 120,
                height = 40,
                preview = {
                    vertical = 'down:50%',
                },
            },
        },
    },
})

local map = vim.keymap.set

---@param desc string
---@return vim.keymap.set.Opts
local opts = function(desc)
    ---@type vim.keymap.set.Opts
    return { desc = desc, remap = true, silent = true }
end

map("n", "<C-p>", fzf.files, opts("Find files"))
map("n", "<C-g>", fzf.files, opts("Find files"))

map("n", "<leader>pf", fzf.files, opts("Find files"))
map("n", "<leader>ps", fzf.live_grep, opts("Search files"))
map('n', "<leader>pb", fzf.buffers, opts('Buffers'))
map('n', "<leader>pd", fzf.diagnostics_workspace, opts('Project Diagnostics'))

map('n', "z=", fzf.spell_suggest, opts('Buffers'))

local ui_select = require "fzf-lua.providers.ui_select"

-- Replace codelens UI select with fzf
ui_select.register({ kind = "codelens" }, true)
