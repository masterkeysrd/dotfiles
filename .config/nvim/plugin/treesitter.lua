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

        if vim.treesitter.query.get(ft, "folds") then
            local win = vim.api.nvim_get_current_win()
            vim.wo[win].foldmethod = "expr"
            vim.wo[win].foldexpr = "v:lua.vim.treesitter.foldexpr()"
        end
    end,
})
