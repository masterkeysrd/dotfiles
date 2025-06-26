local function setup()
    local cwd = vim.fn.getcwd()
    local home = vim.fn.expand("$HOME")

    if cwd == home or
        cwd:find(home .. "/.config/nvim") then
        vim.fn.setenv("GIT_DIR", home .. "/.dotfiles")
        vim.fn.setenv("GIT_WORK_TREE", home)
    end
end

setup()
