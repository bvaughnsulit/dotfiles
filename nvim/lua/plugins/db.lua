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
            vim.g.db_ui_use_nvim_notify = not vim.g.db_ui_disable_info_notifications

            -- g:db_ui_save_location
            -- vim.g.db_ui_env_variable_url =
        end,
    },
}
