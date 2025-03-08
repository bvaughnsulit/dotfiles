local utils = require("config.utils")
local pickers = require("config.pickers")

return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    init = function()
        _G.logger = function(...) Snacks.debug.inspect(...) end
    end,
    opts = function()
        ---@type snacks.Config
        return {
            lazygit = {
                enabled = true,
                config = {
                    git = {
                        paging = {
                            pager = "delta --paging=never " .. (utils.is_system_dark_mode() and "--dark" or "--light"),
                        },
                    },
                },
            },
            notifier = { enabled = true },
            quickfile = { enabled = true },
            bigfile = { enabled = true },
            words = { enabled = true },
            -- toggle = { map = LazyVim.safe_keymap_set },
            statuscolumn = { enabled = false }, -- we set this in options.lua
            terminal = {
                win = {
                    height = 0.95,
                    width = 0.95,
                    -- keys = {
                    --   nav_h = { '<C-h>', term_nav('h'), desc = 'Go to Left Window', expr = true, mode = 't' },
                    --   nav_j = { '<C-j>', term_nav('j'), desc = 'Go to Lower Window', expr = true, mode = 't' },
                    --   nav_k = { '<C-k>', term_nav('k'), desc = 'Go to Upper Window', expr = true, mode = 't' },
                    --   nav_l = { '<C-l>', term_nav('l'), desc = 'Go to Right Window', expr = true, mode = 't' },
                    -- },
                },
            },
            picker = {
                layout = {
                    layout = {
                        backdrop = false,
                        row = 1,
                        width = 0.95,
                        min_width = 80,
                        height = 0.95,
                        border = "none",
                        box = "vertical",
                        {
                            box = "vertical",
                            border = "rounded",
                            title = "{title} {live} {flags}",
                            title_pos = "center",
                            { win = "input", height = 1, border = "bottom" },
                            { win = "list", border = "none" },
                        },
                        { win = "preview", title = "{preview}", height = 0.7, border = "rounded" },
                    },
                },
                formatters = {
                    file = {
                        filename_first = true,
                        truncate = 100,
                    },
                },
                previewers = {
                    diff = {
                        builtin = false,
                        cmd = { "delta" },
                    },
                    git = {
                        builtin = false,
                    },
                },
                win = {
                    input = {
                        keys = {
                            ["<Esc>"] = { "close", mode = { "n", "i" } },
                            ["<c-c>"] = { "<Esc>", mode = { "i" } },
                            ["<c-u>"] = { "preview_scroll_up", mode = { "i", "n" } },
                            ["<c-d>"] = { "preview_scroll_down", mode = { "i", "n" } },
                            ["<c-_>"] = { "toggle_help_input", mode = { "i", "n" } },
                        },
                    },
                },
            },
        }
    end,
    keys = {
        {
            "<leader>gg",
            function() Snacks.lazygit.open() end,
            desc = "Lazygit",
        },
        {
            "<leader>ps",
            function() Snacks.picker.lazy() end,
            desc = "Plugin specs",
        },
        {
            "<leader>pg",
            function() Snacks.picker.git_status() end,
            desc = "Pick Git status",
        },
        {
            "<leader>pb",
            function() Snacks.picker.git_branches() end,
            desc = "Pick Git branch",
        },
    },
    config = function(_, opts)
        require("snacks").setup(opts)
        pickers.register_picker("snacks", {
            find_files = function() Snacks.picker.files() end,
            buffers = function() Snacks.picker.buffers({ current = false }) end,
            live_grep = function() Snacks.picker.grep() end,
            lsp_definitions = function() Snacks.picker.lsp_definitions() end,
            lsp_references = function() Snacks.picker.lsp_references() end,
            lsp_type_definitions = function() Snacks.picker.lsp_type_definitions() end,
            buffer_fuzzy = function() Snacks.picker.lines() end,
            keymaps = function() Snacks.picker.keymaps() end,
            help_tags = function() Snacks.picker.help() end,
            commands = function()
                Snacks.picker.commands({
                    confirm = function(picker, item)
                        picker:close()
                        if item and item.cmd then vim.schedule(function() vim.cmd(item.cmd) end) end
                    end,
                })
            end,
            pickers = function() Snacks.picker.pickers() end,
        })
    end,
}
