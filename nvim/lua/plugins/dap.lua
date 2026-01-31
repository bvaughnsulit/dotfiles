local utils = require("config.utils")

---@type LazySpec
return {
    {
        "https://github.com/mfussenegger/nvim-dap",
        event = "VeryLazy",
        dependencies = {
            "https://github.com/rcarriga/nvim-dap-ui",
            "https://github.com/mxsdev/nvim-dap-vscode-js",
            "https://github.com/mfussenegger/nvim-dap-python",
            "https://github.com/jbyuki/one-small-step-for-vimkind",
            {
                "https://github.com/jay-babu/mason-nvim-dap.nvim",
                dependencies = "https://github.com/mason-org/mason.nvim",
                cmd = { "DapInstall", "DapUninstall" },
                opts = {
                    automatic_setup = true,
                    ensure_installed = {},
                },
            },
            {
                "https://github.com/theHamsta/nvim-dap-virtual-text",
                enabled = false,
            },
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")

            require("dap.ext.vscode").load_launchjs()
            require("dap-python").setup()
            require("dap").defaults.python.exception_breakpoints = {}

            dap.adapters["pwa-node"] = {
                type = "server",
                host = "localhost",
                port = "${port}",
                executable = {
                    command = "node",
                    args = {
                        vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
                        "${port}",
                    },
                },
            }

            dap.configurations.lua = {
                {
                    type = "nlua",
                    request = "attach",
                    name = "osv",
                },
            }

            dap.adapters.nlua = function(callback, config)
                callback({ type = "server", host = config.host or "127.0.0.1", port = config.port or 8086 })
            end
            vim.api.nvim_create_autocmd("VimLeavePre", {
                pattern = "*",
                callback = function() dapui.close() end,
            })

            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "dap-*", "dapui_*" },
                group = utils.augroup("dap_ui_mappings"),
                callback = function(event)
                    vim.schedule(function()
                        vim.keymap.set("n", "q", function() dapui.close() end, {
                            buffer = event.buf,
                            silent = true,
                            desc = "Close DAP UI",
                        })
                    end)
                end,
            })
            vim.api.nvim_create_autocmd("FileType", {
                group = utils.augroup("dap_repl_console"),
                pattern = { "dap-repl", "dapui_console" },
                callback = function() vim.opt_local.wrap = true end,
            })
        end,
        keys = {
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
                "<leader>dl",
                function()
                    vim.ui.input({
                        prompt = "Log message: ",
                    }, function(input)
                        if input then
                            require("dap").toggle_breakpoint(nil, nil, input ~= "" and input or "Logpoint")
                        end
                    end)
                end,
                desc = "Toggle Logpoint",
            },
            {
                "<leader>dC",
                function() require("dap").clear_breakpoints() end,
                desc = "Clear all breakpoints",
            },
            {
                "<leader>dc",
                function()
                    require("dapui").close()
                    require("dapui").open({ layout = 1 })
                    require("dap").continue()
                end,
                desc = "Continue",
            },
            {
                "<leader>dr",
                function()
                    require("dapui").close()
                    require("dapui").open({ layout = 1 })
                    require("dap").run_last()
                end,
                desc = "Run Last",
            },
            {
                "<right>",
                function() require("dap").step_into() end,
                desc = "Step Into",
            },
            {
                "<left>",
                function() require("dap").step_out() end,
                desc = "Step Out",
            },
            {
                "<down>",
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
            {
                "<leader>,d",
                function()
                    local sessions = require("dap").sessions()

                    local session_exists = false
                    for _, session in ipairs(sessions) do
                        local config = session.config.name
                        if config == "nluarepl" then
                            session_exists = true
                            break
                        end
                    end
                    if not session_exists then vim.cmd(":DapNew nluarepl") end

                    local eval_bufnr = nil
                    for _, win in ipairs(vim.fn.getwininfo()) do
                        if vim.fn.getbufinfo(win.bufnr)[1].name:find("dap-eval://lua", 1, true) then
                            eval_bufnr = win.bufnr
                            break
                        end
                    end

                    if eval_bufnr == nil then
                        -- Create a new eval buffer if it doesn't exist
                        local width = math.floor(vim.o.columns * 0.3)

                        vim.cmd(width .. " vsplit dap-eval://lua")
                        vim.api.nvim_buf_set_lines(0, 0, 1, false, { "debug_info()" })
                        vim.cmd("w")

                        vim.keymap.set("n", "q", function()
                            require("dap").repl.close()
                            vim.cmd("hide")
                        end, { buffer = 0, silent = true })
                    else
                        -- if it already exists, execute the lines in the eval buffer
                        vim.bo[eval_bufnr].modified = false
                        local repl = require("dap.repl")
                        local lines = vim.api.nvim_buf_get_lines(eval_bufnr, 0, -1, true)
                        local lines_str = table.concat(lines, "\n")
                        if lines_str ~= "" then
                            repl.execute(lines_str)
                            repl.open()
                        end
                    end
                end,
                desc = "Start nluarepl DAP and open eval buffer",
            },
            --   '<leader>dB',
            --   function()
            --     require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))
            --   end,
            --   'Breakpoint Condition',
        },
    },
    {
        "https://github.com/rcarriga/nvim-dap-ui",
        dependencies = {
            "https://github.com/nvim-neotest/nvim-nio",
        },
        ---@diagnostic disable: missing-fields
        ---@type dapui.Config
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
                            size = 0.05,
                        },
                        {
                            id = "watches",
                            size = 0.05,
                        },
                        {
                            id = "repl",
                            size = 0.1,
                        },
                    },
                    position = "right",
                    size = 0.35,
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
        ---@diagnostic enable: missing-fields
    },
    {
        "https://github.com/jbyuki/one-small-step-for-vimkind",
        init = function()
            if vim.fn.getenv("INIT_DEBUG") == "true" then require("osv").launch({ port = 8086, blocking = true }) end
        end,
        keys = {
            {
                "<leader>dL",
                function() require("osv").launch({ port = 8086 }) end,
                desc = "Debug this Neovim instance (OSV)",
            },
        },
    },
    {
        "https://github.com/mfussenegger/nluarepl",
        event = "VeryLazy",
    },
}
