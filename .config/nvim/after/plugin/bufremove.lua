local ok, bufremove = pcall(require, 'mini.bufremove')
local notify_opts = { title = 'UI' }

if not ok then
    vim.notify('bufremove is not installed', vim.log.levels.ERROR, notify_opts)
    return
end

bufremove.setup({
    set_vim_settings = true,
    silent = true,
})

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

    bufremove.delete(bufnr)
end

vim.keymap.set('n', '<leader>bd', close_buffer, { silent = true, desc = 'Delete buffer' })
vim.keymap.set('n', '<C-w>', close_buffer, { noremap = true, silent = true, desc = 'Close tab' })
