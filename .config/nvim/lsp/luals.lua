---@type vim.lsp.Config
return {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        root_markers = { ".luarc.json", ".luarc.jsonc" },
        settings = {
                Lua = {
                        runtime = {
                                version = "LuaJIT",
                        },
                        workspace = {
                                checkThirdParty = false,
                                library = {
                                        vim.env.VIMRUNTIME,
                                        '${3rd}/luv/library',
                                }
                        },
                        hint = {
                                enable = true
                        },
                        telemetry = {
                                enable = false
                        },
                        codeLens = {
                                enable = true
                        },
                        completion = {
                                callSnippet = "Replace",
                        }
                }
        }
}
