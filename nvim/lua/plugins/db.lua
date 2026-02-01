---@module 'lazy'
---@type LazySpec
return {
    { "https://github.com/tpope/vim-dadbod" },
    {
        "https://github.com/kristijanhusak/vim-dadbod-ui",
        dependencies = {
            { "https://github.com/tpope/vim-dadbod" },
            {
                "https://github.com/kristijanhusak/vim-dadbod-completion",
                ft = { "sql", "mysql", "plsql" },
            },
        },
        cmd = {
            "DBUI",
            "DBUIToggle",
            "DBUIAddConnection",
            "DBUIFindBuffer",
        },
        config = function()
            vim.g.db_ui_use_nerd_fonts = 1
            vim.g.db_ui_show_help = 0
            vim.g.db_ui_disable_info_notifications = 1
            vim.g.db_ui_use_nvim_notify = 1

            local project_config_dir = require("config.utils").get_project_config_dir()
            if project_config_dir then vim.g.db_ui_save_location = project_config_dir .. "/db/" end
        end,
        keys = {
            { "<leader>ss", "<cmd>DBUIToggle<cr>", desc = "Toggle DB UI" },
        },
    },
}
