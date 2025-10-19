local utils = require("config.utils")
local git = require("config.git")

vim.g.IS_EXPLORER_PINNED = false

return {
    "nvim-neo-tree/neo-tree.nvim",
    enabled = true,
    branch = "v3.x",
    event = "VeryLazy",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
    },
    opts = function()
        local neotree = require("neo-tree")
        local def = require("neo-tree.defaults")

        ---@diagnostic disable: missing-fields
        ---@type neotree.Config?
        local opts = {
            sources = {
                "filesystem",
                "git_status",
                "document_symbols",
            },
            source_selector = {
                winbar = true,
                show_scrolled_off_parent_node = true,
                sources = {
                    { source = "filesystem" },
                    { source = "git_status" },
                    { source = "document_symbols" },
                },
            },
            default_component_configs = {
                container = {
                    enable_character_fade = false,
                },
                indent = {
                    indent_size = 1,
                    -- indent_marker = "│",
                    -- last_indent_marker = "└",
                    indent_marker = "▏",
                    last_indent_marker = "▏",
                },
                modified = {
                    symbol = "*",
                },
                git_status = {
                    symbols = {
                        deleted = "", -- '',
                        modified = "",
                        renamed = "➜",
                        untracked = "﬒",
                        ignored = "",
                        unstaged = "󰝦",
                        staged = "󰝥",
                        conflict = "",
                    },
                    align = "left",
                },
                file_size = { enabled = false },
                type = { enabled = false },
                last_modified = { enabled = false },
                symlink_target = { enabled = true },
            },
            hide_root_node = true,
            -- enable_diagnostics = false,
            use_popups_for_input = true,
            enable_git_status = true,
            event_handlers = {
                {
                    event = "file_opened",
                    handler = function(_)
                        if not vim.g.IS_EXPLORER_PINNED then require("neo-tree.sources.manager").close_all() end
                    end,
                },
            },
            window = {
                width = 0.25,
                position = "left",
                mappings = {
                    ["/"] = {},
                    ["<tab>"] = { "toggle_node" },
                    ["z"] = "noop",
                    ["s"] = "noop",
                    ["y"] = "noop",
                    ["e"] = "noop",
                    ["v"] = "open_vsplit",
                    ["d"] = {
                        "copy",
                        config = {
                            ---@type ("none"|"relative"|"absolute")
                            show_path = "relative",
                        },
                    },
                    ["p"] = {
                        "toggle_preview",
                        config = { use_float = true, use_image_nvim = false },
                    },
                    ["c"] = {
                        "add",
                        config = {
                            ---@type ("none"|"relative"|"absolute")
                            show_path = "relative",
                        },
                    },
                    ["X"] = "delete",
                    -- ["c"] = "copy_to_clipboard",
                    ["x"] = "cut_to_clipboard",
                    ["P"] = "paste_from_clipboard",
                },
            },
            filesystem = {
                bind_to_cwd = false,
                filtered_items = {
                    visible = true,
                    hide_dotfiles = false,
                    never_show = { ".DS_Store" },
                },
                follow_current_file = {
                    enabled = true,
                    leave_dirs_open = true,
                },
                window = {
                    mappings = {
                        ["f"] = { "fuzzy_finder" },
                    },
                },
            },
            git_status = {
                window = {
                    mappings = {
                        ["f"] = "noop",
                        ["gg"] = "noop",
                        ["a"] = "git_add_all",
                        ["c"] = "git_commit",
                        ["P"] = "git_push",
                        ["X"] = "git_revert_file",
                        ["<space>"] = "git_add_file",
                        ["<c-space>"] = "git_unstage_file",
                    },
                },
            },
        }
        ---@diagnostic enable: missing-fields

        vim.keymap.set(
            "n",
            "<leader>ee",
            function()
                require("neo-tree.command").execute({
                    source = "filesystem",
                    action = "focus",
                    git_base = git.get_git_base().hash,
                    toggle = true,
                    reveal = true,
                    dir = Snacks.git.get_root(require("neo-tree.sources.manager").get_path_to_reveal(false)),
                })
            end,
            {}
        )

        utils.create_cmd_and_map(
            "ToggleIsExplorerPinned",
            nil,
            function() vim.g.IS_EXPLORER_PINNED = not vim.g.IS_EXPLORER_PINNED end,
            "Toggle Neotree auto close"
        )

        local toggle_git_explorer = function()
            require("neo-tree.command").execute({
                source = "git_status",
                action = "focus",
                git_base = git.get_git_base().hash,
                toggle = true,
                reveal = true,
            })
        end

        utils.create_cmd_and_map("GitDiffExplore", "<leader>eg", toggle_git_explorer, "Explore Git Diff from Main")

        utils.create_cmd_and_map("Close Neo-tree", "<leader>eq", function()
            vim.cmd("Neotree close")
            vim.g.IS_EXPLORER_PINNED = false
        end, "Close Neo-tree")

        vim.api.nvim_create_autocmd("TermClose", {
            pattern = "*lazygit",
            callback = function() require("neo-tree.sources.git_status").refresh() end,
        })

        vim.api.nvim_create_autocmd("VimLeavePre", {
            pattern = "*",
            callback = function() vim.cmd("Neotree close") end,
        })
        return opts
    end,
}
