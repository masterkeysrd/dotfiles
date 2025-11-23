local ok, autotag = pcall(require, 'nvim-ts-autotag')
local notify_opts = { title = 'UI' }

if not ok then
    vim.notify('nvim-ts-autotag is not installed', vim.log.levels.ERROR, notify_opts)
    return
end

autotag.setup({
    opts = {
        -- Defaults
        enable_close = true,          -- Auto close tags
        enable_rename = true,         -- Auto rename pairs of tags
        enable_close_on_slash = false -- Auto close on trailing </
    },
})
