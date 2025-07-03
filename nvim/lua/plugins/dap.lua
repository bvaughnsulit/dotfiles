local utils = require("config.utils")

return {
    {
        "mfussenegger/nvim-dap",
        event = "VeryLazy",
        -- TODO
        -- DAP repl completion
        -- widgets
        -- dap.status()
        -- events/listeners
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "mxsdev/nvim-dap-vscode-js",
            "mfussenegger/nvim-dap-python",
            "jbyuki/one-small-step-for-vimkind",
            {
                "jay-babu/mason-nvim-dap.nvim",
                dependencies = "mason.nvim",
                cmd = { "DapInstall", "DapUninstall" },
                opts = {
                    automatic_setup = true,
                    ensure_installed = {},
                },
            },
            {
                "theHamsta/nvim-dap-virtual-text",
                enabled = false,
            },
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")
            dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open({ layout = 1 }) end

            require("dap.ext.vscode").load_launchjs()
            require("dap-python").setup()
            -- require('dap-vscode-js').setup({
            --   debugger_cmd = { 'js-debug-adapter' },
            --   -- debugger_path = vim.fn.stdpath('data')
            --   --   .. '/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js',
            --   adapters = {
            --     'pwa-node',
            --     'pwa-chrome',
            --     'pwa-msedge',
            --     'node-terminal',
            --     'pwa-extensionHost',
            --   },
            -- })
            require("dap").defaults.python.exception_breakpoints = { "uncaught" }
            dap.adapters["pwa-node"] = {
                type = "server",
                port = "${port}",
                executable = {
                    command = "js-debug-adapter",
                    args = { "${port}" },
                },
            }

            dap.configurations.lua = {
                {
                    type = "nlua",
                    request = "attach",
                    name = "Attach to running Neovim instance",
                },
            }

            dap.adapters.nlua = function(callback, config)
                callback({ type = "server", host = config.host or "127.0.0.1", port = config.port or 8086 })
            end
            vim.api.nvim_create_autocmd("VimLeavePre", {
                pattern = "*",
                callback = function() dapui.close() end,
            })
        end,
        keys = {
            {
                "<leader>dl",
                function() require("osv").launch({ port = 8086 }) end,
                desc = "Debug this Neovim instance",
            },
            {
                "<leader>dd",
                function() require("dapui").toggle({ layout = 1 }) end,
                desc = "Toggle DAP UI",
            },
            {
                "<leader>de",
                function() require("dap").defaults.python.exception_breakpoints = { "uncaught" } end,
                desc = "Break on Uncaught Exceptions",
            },
            {
                "<leader>dE",
                function() require("dap").defaults.python.exception_breakpoints = { "raised", "uncaught" } end,
                desc = "Break on All Exceptions",
            },
            {
                "<leader>db",
                function() require("dap").toggle_breakpoint() end,
                desc = "Toggle Breakpoint",
            },
            {
                "<leader>dC",
                function() require("dap").clear_breakpoints() end,
                desc = "Clear all breakpoints",
            },
            {
                "<leader>dc",
                function() require("dap").continue() end,
                desc = "Continue",
            },
            {
                "<leader>di",
                function() require("dap").step_into() end,
                desc = "Step Into",
            },
            {
                "<leader>dO",
                function() require("dap").step_out() end,
                desc = "Step Out",
            },
            {
                "<leader>do",
                function() require("dap").step_over() end,
                desc = "Step Over",
            },
            {
                "<leader>dP",
                function() require("dap").pause() end,
                desc = "Pause",
            },
            {
                "<leader>dR",
                function() require("dap").repl.toggle() end,
                desc = "Toggle REPL",
            },
            {
                "<leader>dx",
                function() require("dap").terminate() end,
                desc = "Terminate",
            },
            {
                "<leader>dw",
                function() require("dap.ui.widgets").hover() end,
                desc = "Widgets",
            },
            {
                "<leader>ds",
                function() require("dap").session() end,
                desc = "Session",
            },
            { "<leader>dU", function() require("dap").down() end, desc = "DAP Up in stacktrace" },
            { "<leader>dD", function() require("dap").up() end, desc = "DAP Down in stacktrace" },
            --   '<leader>dB',
            --   function()
            --     require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))
            --   end,
            --   'Breakpoint Condition',
        },
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = {
            "nvim-neotest/nvim-nio",
        },
        opts = {
            controls = {
                element = "repl",
                icons = {
                    disconnect = "",
                    pause = "",
                    play = "",
                    run_last = "",
                    step_back = "",
                    step_into = "",
                    step_out = "",
                    step_over = "",
                },
            },
            expand_lines = false,
            icons = {
                collapsed = "",
                current_frame = "",
                expanded = "",
            },
            layouts = {
                { -- 1
                    elements = {
                        {
                            id = "console",
                            size = 0.45,
                        },
                        {
                            id = "scopes",
                            size = 0.35,
                        },
                        {
                            id = "stacks",
                            size = 0.08,
                        },
                        {
                            id = "watches",
                            size = 0.08,
                        },
                        {
                            id = "repl",
                            size = 0.04,
                        },
                    },
                    position = "right",
                    size = 60,
                },
                { -- 2
                    elements = {
                        {
                            id = "console",
                            size = 1,
                        },
                    },
                    position = "right",
                    size = 0.35,
                },
            },
        },
    },
    {
        {
            "jbyuki/one-small-step-for-vimkind",
            init = function()
                if vim.fn.getenv("INIT_DEBUG") == "true" then
                    require("osv").launch({ port = 8086, blocking = true })
                end
            end,
        },
    },
}
