vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("masterkeysrd/dotfiles_setup", { clear = true }),
    desc = "Dotfiles setup",
    callback = function()
        local cwd = vim.fn.getcwd()
        local home = vim.fn.expand("$HOME")

        if cwd == home or
            cwd:find(home .. "/.config/nvim") then
            vim.fn.setenv("GIT_DIR", home .. "/.dotfiles")
            vim.fn.setenv("GIT_WORK_TREE", home)
        end
    end
})

vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('masterkeysrd/close_with_q', { clear = true }),
    desc = 'Close with <q>',
    pattern = {
        'git',
        'help',
        'man',
        'qf',
        'scratch',
    },
    callback = function(args)
        vim.keymap.set('n', 'q', '<cmd>quit<cr>', { buffer = args.buf })
    end,
})

vim.api.nvim_create_autocmd('CmdwinEnter', {
    group = vim.api.nvim_create_augroup('masterkeysrd/execute_cmd_and_stay', { clear = true }),
    desc = 'Execute command and stay in the command-line window',
    callback = function(args)
        vim.keymap.set({ 'n', 'i' }, '<S-CR>', '<cr>q:', { buffer = args.buf })
    end,
})

vim.api.nvim_create_autocmd('BufReadPost', {
    group = vim.api.nvim_create_augroup('masterkeysrd/last_location', { clear = true }),
    desc = 'Go to the last location when opening a buffer',
    callback = function(args)
        local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
        local line_count = vim.api.nvim_buf_line_count(args.buf)
        if mark[1] > 0 and mark[1] <= line_count then
            vim.cmd 'normal! g`"zz'
        end
    end,
})
