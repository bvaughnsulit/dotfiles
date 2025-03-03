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
                win = {
                    input = {
                        keys = {
                            ["<Esc>"] = { "close", mode = { "n", "i" } },
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
    },
    config = function(_, opts)
        require("snacks").setup(opts)
        pickers.register_picker("snacks", {
            find_files = function() Snacks.picker.files() end,
            buffers = function() Snacks.picker.buffers() end,
            live_grep = function() Snacks.picker.grep() end,
            lsp_definitions = function() Snacks.picker.lsp_definitions() end,
            lsp_references = function() Snacks.picker.lsp_references() end,
            lsp_type_definitions = function() Snacks.picker.lsp_type_definitions() end,
            buffer_fuzzy = function() Snacks.picker.lines() end,
            keymaps = function() Snacks.picker.keymaps() end,
            help_tags = function() Snacks.picker.help() end,
            commands = function() Snacks.picker.commands() end,
        })
    end,
}
