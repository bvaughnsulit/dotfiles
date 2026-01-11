return {
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        -- dev = true,
        ---@module "noice"
        ---@type NoiceConfig
        ---@diagnostic disable-next-line: missing-fields
        opts = {
            cmdline = {
                enabled = true,
                view = "cmdline",
            },
            messages = {
                enabled = true,
                view = "notify",
            },
            lsp = {
                progress = { enabled = false },
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["cmp.entry.get_documentation"] = true,
                },
                signature = {
                    enabled = true,
                    auto_open = {
                        enabled = true,
                    },
                },
            },
            presets = {
                long_message_to_split = true,
                lsp_doc_border = true,
                bottom_search = true,
            },
            views = {
                mini = {
                    position = {
                        col = -1,
                        row = 0,
                    },
                    align = "message-right",
                    size = {
                        height = 1,
                        width = "auto",
                    },
                    win_options = { winblend = 0 },
                },
                cmdline = {
                    win_options = { winblend = 0 },
                    position = {
                        row = -1,
                    },
                },
                virtualtext = {
                    hl_group = "CurSearch",
                },
                popup = {
                    enter = false,
                },
                notify = {
                    replace = true,
                },
            },
            routes = {
                {
                    view = "mini",
                    filter = {
                        event = "msg_show",
                        find = "B written$",
                    },
                },
                {
                    view = "cmdline",
                    filter = {
                        event = "msg_showmode",
                    },
                },
            },
            ---@type table<string, NoiceCommand>
            commands = {
                filterTest = {
                    view = "popup",
                    opts = { enter = true, format = "details" },
                    filter = {
                        any = {
                            { event = { "msg_ruler", "msg_showcmd" } },
                        },
                    },
                    filter_opts = { reverse = true },
                },
                customAll = {
                    view = "popup",
                    opts = { enter = true, format = "details" },
                    filter = {
                        ["not"] = {
                            event = { "msg_ruler", "msg_showcmd" },
                        },
                    },
                    filter_opts = { reverse = true },
                },
            },
        },
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },
        keys = {
            -- { "<c-f>", false },
            -- { "<c-b>", false },
            {
                "<leader>,M",
                function() require("noice").cmd("filterTest") end,
                desc = "Message History",
            },
            {
                "<leader>,m",
                function() require("noice").cmd("customAll") end,
                desc = "All Messages",
            },
        },
    },
}
