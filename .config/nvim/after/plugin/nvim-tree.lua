local add = require('vim-pack').add
local icons = require('masterkeysrd.icons')

add {
    {
        src = 'nvim-tree/nvim-tree.lua',
        module_name = 'nvim-tree',
        opts = function()
            return {
                disable_netrw = false,
                hijack_cursor = true,
                sort = {
                    sorter = "case_sensitive",
                },
                view = {
                    width = 35,
                    signcolumn = "yes",
                },
                actions = {
                    change_dir = {
                        restrict_above_cwd = true,
                    },
                    remove_file = {
                        close_window = false, -- Prevents breaking the tabs layout.
                    },
                },
                renderer = {
                    group_empty = true,
                    highlight_git = true,
                    root_folder_label = ":t",
                    indent_markers = {
                        enable = true,
                        inline_arrows = true,
                        icons = {
                            corner = icons.border.corner,
                            edge = icons.border.vertical,
                            item = icons.border.vertical,
                            bottom = icons.border.horizontal,
                            none = icons.border.none,
                        },
                    },
                    icons = {
                        show = {
                            file = true,
                            folder = true,
                            folder_arrow = true,
                            git = true,
                        },
                        glyphs = {
                            default = "",
                            symlink = "",
                            git = {
                                unstaged = "",
                                staged = "S",
                                unmerged = "",
                                renamed = "➜",
                                deleted = "",
                                untracked = "U",
                                ignored = "◌",
                            },
                            folder = {
                                default = "",
                                open = "",
                                empty = "",
                                empty_open = "",
                                symlink = "",
                            },
                        },
                    },
                },
                filters = {
                    git_ignored = false,
                    custom = { '^.git$' }
                },
                diagnostics = {
                    enable = true,
                    icons = {
                        hint = icons.diagnostics.HINT,
                        info = icons.diagnostics.INFO,
                        warning = icons.diagnostics.WARN,
                        error = icons.diagnostics.ERROR,
                    },
                },
                on_attach = function(bufnr)
                    local api = require("nvim-tree.api")

                    local function opts(desc)
                        return { desc = desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
                    end

                    api.config.mappings.default_on_attach(bufnr)

                    vim.keymap.set('n', '<C-t>', api.tree.change_root_to_parent, opts('Up'))
                    vim.keymap.set('n', '?', api.tree.toggle_help, opts('Toggle help'))
                    vim.keymap.set('n', 'q', api.tree.close, opts('Close'))
                    vim.keymap.set('n', '<C-W>', api.tree.close, opts('Close'))
                    vim.keymap.set('n', '<C-e>', api.tree.close, opts('Close'))
                end,
            }
        end,
        on_setup = function()
            local api = require("nvim-tree.api")

            api.events.subscribe(api.events.Event.FileCreated, function(file)
                vim.cmd("edit " .. file.fname)
            end)

            local map = vim.keymap.set
            local function opts(desc)
                return { noremap = true, silent = true, desc = desc }
            end

            local function open_tree_current_file()
                api.tree.toggle({
                    find_file = true,
                    focus = true,
                })
            end

            local function find_current_file()
                api.tree.find_file({
                    open = true,
                    focus = true,
                })
            end


            map("n", "<leader>e", open_tree_current_file, opts("Toggle NvimTree"))
            map("n", "<leader>E", find_current_file, opts("Toggle NvimTree"))
            map("n", "<C-e>", open_tree_current_file, opts("Toggle NvimTree"))
            map("n", "<C-b>", find_current_file, opts("Toggle NvimTree"))
        end,
    }
}
