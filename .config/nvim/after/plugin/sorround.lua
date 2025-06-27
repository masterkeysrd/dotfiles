local ok, sorround = pcall(require, "mini.surround")
local notify_opts = { title = "Editor" }

if not ok then
    vim.notify("mini.surround not found", vim.log.levels.ERROR, notify_opts)
    return
end

sorround.setup({})
