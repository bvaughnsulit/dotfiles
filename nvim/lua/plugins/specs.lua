---@type LazySpec
return {
    {
        "/local-config",
        dev = true,
        event = "VeryLazy",
        config = function() pcall(require, "local-config") end,
    },
    {
        "https://github.com/numToStr/Comment.nvim",
        event = "VeryLazy",
        dependencies = {
            "https://github.com/JoosepAlviste/nvim-ts-context-commentstring",
        },
        opts = function()
            return {
                pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
            }
        end,
    },
    {
        "https://github.com/windwp/nvim-autopairs",
        event = "VeryLazy",
        opts = {},
    },
    {
        "https://github.com/eandrju/cellular-automaton.nvim",
        cmd = "Oops",
        config = function()
            vim.api.nvim_create_user_command(
                "Oops",
                function() require("cellular-automaton").start_animation("make_it_rain") end,
                {}
            )
        end,
    },
    {
        "https://github.com/rmagatti/auto-session",
        lazy = false,
        ---@module "auto-session"
        ---@type AutoSession.Config
        opts = {
            suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
        },
    },
    {
        "https://github.com/tpope/vim-sleuth",
        event = "BufReadPre",
    },
    {
        "https://github.com/tpope/vim-repeat",
        event = "VeryLazy",
    },
    {
        "https://github.com/tpope/vim-fugitive",
        cmd = "G",
    },
    {
        "https://github.com/chrisgrieser/nvim-various-textobjs",
        event = "VeryLazy",
        opts = {
            keymaps = {
                useDefaults = true,
                disabledDefaults = { "gc" },
            },
        },
    },
    {
        "https://github.com/kevinhwang91/nvim-bqf",
        event = "VeryLazy",
        ---@diagnostic disable: missing-fields
        ---@module "bqf"
        ---@type BqfConfig
        opts = {
            preview = {
                auto_preview = false,
            },
        },
        ---@diagnostic enable: missing-fields
    },
    {
        "https://github.com/abecodes/tabout.nvim",
        event = "VeryLazy",
    },
    {
        "https://github.com/rcarriga/nvim-notify",
        enabled = true,
        opts = {
            timeout = 2000,
            stages = "static",
            max_height = function() return math.floor(vim.o.lines * 0.75) end,
            max_width = function() return math.floor(vim.o.columns * 0.75) end,
            top_down = false,
        },
        init = function() vim.notify = require("notify") end,
    },
    {
        "https://github.com/lukas-reineke/indent-blankline.nvim",
        event = "VeryLazy",
        main = "ibl",
        ---@module "ibl"
        ---@type ibl.config
        opts = {
            scope = { enabled = false },
            indent = {
                char = "▏",
                tab_char = "▏",
            },
        },
        exclude = {
            filetypes = {
                "Trouble",
                "help",
                "lazy",
                "mason",
                "neo-tree",
                "notify",
                "snacks_notif",
                "snacks_terminal",
                "snacks_win",
                "trouble",
            },
        },
    },
    {
        "https://github.com/mbbill/undotree",
        cmd = "UndotreeToggle",
    },
    {
        "https://github.com/folke/ts-comments.nvim",
        event = "VeryLazy",
    },
    {
        "https://github.com/folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = "snacks.nvim", words = { "Snacks" } },
            },
        },
    },
    { "https://github.com/MunifTanjim/nui.nvim" },
    { "https://github.com/petertriho/nvim-scrollbar.git", cond = false },
    { "https://github.com/dstein64/nvim-scrollview.git", cond = false },
    { "https://github.com/lewis6991/satellite.nvim.git", cond = false },
    { "https://github.com/kristijanhusak/vim-dadbod-ui.git", cond = false },
    { "https://github.com/tpope/vim-dadbod.git", cond = false },
}
