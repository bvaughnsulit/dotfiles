local utils = require("config.utils")

return {
    {
        "olimorris/codecompanion.nvim",
        event = "VeryLazy",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        opts = {
            opts = {
                -- log_level = "INFO",
            },
            strategies = {
                chat = {
                    keymaps = {
                        close = {
                            modes = {
                                n = "q",
                                i = "<C-c>",
                            },
                            callback = "keymaps.close",
                            description = "Close Chat",
                        },
                        stop = {
                            modes = {
                                n = { "<C-c>", "<Esc>" },
                            },
                            callback = "keymaps.stop",
                            description = "Stop Request",
                        },
                        send = {
                            modes = {
                                n = { "<CR>", "<C-s>", "<leader>w" },
                                i = "<C-s>",
                            },
                            callback = "keymaps.send",
                            description = "Send",
                        },
                    },
                },
            },
            adapters = {
                copilot = function()
                    return require("codecompanion.adapters").extend("copilot", {
                        schema = {
                            model = {
                                default = "claude-3.5-sonnet",
                            },
                        },
                    })
                end,
            },
            display = {
                chat = {
                    show_header_separator = true,
                    show_settings = true,
                    show_token_count = false,
                    start_in_insert_mode = true,
                },
            },
        },
        config = function(_, opts)
            require("codecompanion").setup(opts)

            utils.create_cmd_and_map(
                "",
                { mode = "v", lhs = "<leader>ac", opts = {} },
                ":'<,'>CodeCompanionChat<CR>",
                "Send visual selection to AI chat"
            )

            utils.create_cmd_and_map("", "<leader>ac", ":CodeCompanionChat<CR>", "Open AI chat window")
        end,
    },
}
