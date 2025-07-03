local utils = require("config.utils")
return {
    ---@type LazySpec
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons", lazy = true },
    commit = "640260d7c2d9",
    event = "VeryLazy",
    config = function()
        require("lualine").setup({
            options = {
                icons_enabled = true,
                theme = "auto",
                component_separators = { left = "", right = "" }, --
                section_separators = { left = "", right = "" },
                disabled_filetypes = {
                    statusline = {},
                    winbar = { "dap-repl", "neo-tree" },
                },
                ignore_focus = {
                    "neo-tree",
                },
                always_divide_middle = true,
                globalstatus = true,
                refresh = {
                    statusline = 1000,
                    winbar = 1000,
                },
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = {},
                lualine_c = { "branch" },
                lualine_x = {
                    "progress",
                    "location",
                },
                lualine_y = { "filetype" },
                lualine_z = {
                    function() return require("osv").is_running() and "DEBUG" or "" end,
                },
            },
            winbar = {
                lualine_a = {
                    function() return utils.get_path_tail(vim.loop.cwd()) end,
                },
                lualine_b = { "diagnostics" },
                lualine_c = {
                    {
                        "filename",
                        symbols = { modified = "*" },
                        path = 1,
                    },
                },
                lualine_x = {},
                lualine_y = {},
                lualine_z = {},
            },
            inactive_winbar = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = {
                    {
                        "filename",
                        symbols = { modified = "*" },
                    },
                },
                lualine_x = {},
                lualine_y = {},
                lualine_z = {},
            },
            extensions = {},
        })
    end,
}
