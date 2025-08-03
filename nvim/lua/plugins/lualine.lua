local utils = require("config.utils")
local git = require("config.git")

return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons", lazy = true },
    commit = "640260d7c2d9",
    event = "VeryLazy",
    opts = function()
        local is_top_right_win = function()
            local winnr = vim.api.nvim_get_current_win()
            local win_info = vim.fn.getwininfo(winnr)[1]
            local win_pos = vim.api.nvim_win_get_position(winnr)

            local hits_max_width = (vim.o.columns - (win_pos[2] + win_info.width)) < 3
            if win_info.winbar == 1 and win_pos[1] == 0 then return hits_max_width end
            return false
        end

        local tab_component = {
            "tabs",
            cond = function()
                -- return #vim.api.nvim_list_tabpages() > 1
                return is_top_right_win()
            end,
            show_modified_status = false,
        }

        local opts = {
            options = {
                component_separators = { left = "", right = "" }, --
                disabled_filetypes = {
                    statusline = {},
                    winbar = { "dap-repl", "neo-tree" },
                },
                ignore_focus = {
                    "neo-tree",
                    "aerial",
                    "dap-repl",
                    "dapui_console",
                    "dapui_scopes",
                    "dapui_watches",
                    "dapui_stacks",
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
                lualine_c = {
                    {
                        "branch",
                        icon = "󰘬",
                    },
                    {
                        function()
                            local git_base = git.get_git_base().name
                            if git_base == "merge_base" then
                                return "(" .. git.get_default_branch_name() .. "...HEAD)"
                            else
                                return "(" .. git_base .. ")"
                            end
                        end,
                    },
                },
                lualine_x = {
                    function()
                        local dap_sessions = {}
                        for _, session in ipairs(require("dap").sessions()) do
                            table.insert(dap_sessions, session.config.type or session.config.name)
                        end
                        if #dap_sessions == 0 then return "" end
                        return ":" .. table.concat(dap_sessions, ",")
                    end,
                    "searchcount",
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
                lualine_x = { tab_component },
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
                lualine_x = { tab_component },
                lualine_y = {},
                lualine_z = {},
            },
            extensions = {},
        }
        return opts
    end,
}
