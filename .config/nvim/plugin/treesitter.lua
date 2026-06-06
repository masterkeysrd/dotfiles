local parsers = {
    'bash',
    'c',
    'cpp',
    'fish',
    'gitcommit',
    'go',
    'graphql',
    'html',
    'hyprlang',
    'java',
    'javascript',
    'json',
    'json5',
    'lua',
    'markdown',
    'markdown_inline',
    'python',
    'query',
    'rasi',
    'regex',
    'rust',
    'scss',
    'toml',
    'tsx',
    'typescript',
    'vim',
    'vimdoc',
    'yaml',
}

-- Highlight, edit, and navigate code.
vim.pack.add {
    {
        src = 'https://github.com/nvim-treesitter/nvim-treesitter',
        opts = {
            modules = {},
            ensure_installed = { 'lua', 'go' },
            ignore_install = {},
            auto_install = true,
            sync_install = false,
            highlight = {
                enable = true,
            },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<C-space>",
                    node_incremental = "<C-space>",
                    scope_incremental = false,
                    node_decremental = "<bs>",
                },
            },
        },
        on_setup = function()
            -- Main-branch nvim-treesitter ships queries under `runtime/queries/`,
            -- which isn't on rtp by default. Prepend it so highlights/folds/indents
            -- are visible to `vim.treesitter.start`.
            local init = vim.api.nvim_get_runtime_file('lua/nvim-treesitter/init.lua', false)[1]
            if init then
                vim.opt.runtimepath:prepend(vim.fn.fnamemodify(init, ':h:h:h') .. '/runtime')
            end

            require('nvim-treesitter').install(parsers):wait(300000)
        end,
    },
    {
        src = 'https://github.com/nvim-treesitter/nvim-treesitter-context',
        module_name = 'treesitter-context',
        opts = {
            -- Avoid the sticky context from growing a lot.
            max_lines = 3,
            -- Match the context lines to the source code.
            multiline_threshold = 1,
            -- Disable it when the window is too small.
            min_window_height = 20,
        },
        on_setup = function()
            vim.keymap.set('n', '[c', function()
                -- Jump to previous change when in diffview.
                if vim.wo.diff then
                    return '[c'
                else
                    vim.schedule(function()
                        require('treesitter-context').go_to_context()
                    end)
                    return '<Ignore>'
                end
            end, { desc = 'Jump to upper context', expr = true })
        end,
    },
}

local disabled = {}
local ft_lang_map = {}

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("treesitter#highlight", { clear = true }),
    callback = function(args)
        local buf = args.buf
        if not vim.api.nvim_buf_is_loaded(buf) then
            return
        end

        local ft = vim.bo[buf].filetype
        if disabled[ft] then
            return
        end

        local lang = ft_lang_map[ft]
        if lang then
            vim.treesitter.language.register(lang, ft)
            ft_lang_map[ft] = nil
        end

        local ok, parser = pcall(vim.treesitter.get_parser, buf, nil, { error = false })
        if not ok or not parser then
            disabled[ft] = true
            return
        end

        vim.treesitter.start(buf, parser:lang())

        if vim.treesitter.query.get(ft, "folds") then
            local win = vim.api.nvim_get_current_win()
            vim.wo[win].foldmethod = "expr"
            vim.wo[win].foldexpr = "v:lua.vim.treesitter.foldexpr()"
        end
    end,
})
