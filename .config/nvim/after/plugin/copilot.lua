local ok, copilot = pcall(require, 'copilot.lua')
local notify_opts = { title = 'Editor' }

if not ok then
    vim.notify('copilot.lua is not installed', vim.log.levels.ERROR, notify_opts)
    return
end

copilot.setup({
    nes = {
        enabled = true,
    }
})
