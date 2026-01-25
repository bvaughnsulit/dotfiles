local default_ai_cli = "claude"
local ai_chat_cli = "claude_haiku"

return {
    {
        "https://github.com/CopilotC-Nvim/CopilotChat.nvim",
        event = "VeryLazy",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
    },
    {
        "https://github.com/folke/sidekick.nvim",
        dev = true,
        ---@class sidekick.Config
        opts = {
            nes = { enabled = false },
            cli = {
                win = {
                    split = {
                        width = 0.4,
                    },
                    bo = {
                        buflisted = true,
                    },
                    keys = {
                        buffers = false,
                        files = false,
                        prompt = false,
                        nav_left = false,
                        nav_down = false,
                        nav_up = false,
                        nav_right = false,
                        -- TODO safe close win
                    },
                },
                mux = {
                    enabled = false,
                },
                tools = {
                    -- TODO settings json flag
                    claude = { cmd = { "claude" } },
                    claude_opus = { cmd = { "claude", "--model", "opus" } },
                    claude_haiku = { cmd = { "claude", "--model", "haiku" } },
                    claude_sonnet = { cmd = { "claude", "--model", "sonnet" } },
                },
            },
        },
        keys = {
            {
                "<tab>",
                function()
                    if not require("sidekick").nes_jump_or_apply() then
                        return "<Tab>" -- fallback to normal tab
                    end
                end,
                expr = true,
                desc = "Goto/Apply Next Edit Suggestion",
            },
            {
                "<leader>aa",
                function()
                    require("sidekick.cli").toggle({
                        name = default_ai_cli,
                        focus = true,
                        filter = { external = false },
                    })
                end,
                desc = "Sidekick Toggle CLI",
            },
            {
                "<leader>ac",
                function()
                    require("sidekick.cli").toggle({
                        name = ai_chat_cli,
                        focus = true,
                    })
                end,
                desc = "Sidekick Toggle CLI chat",
            },
            {
                "<leader>aA",
                function() require("sidekick.cli").select({ filter = { installed = true } }) end,
                desc = "Select AI CLI",
            },
            {
                "<leader>at",
                function()
                    require("sidekick.cli").send({
                        msg = "{this}",
                        name = default_ai_cli,
                    })
                end,
                mode = { "x", "n" },
                desc = "Send This",
            },
            {
                "<leader>af",
                function()
                    require("sidekick.cli").send({
                        msg = "{file}",
                        name = default_ai_cli,
                    })
                end,
                desc = "Send File",
            },
            {
                "<leader>av",
                function()
                    require("sidekick.cli").send({
                        msg = "{selection}",
                        name = default_ai_cli,
                    })
                end,
                mode = { "x" },
                desc = "Send Visual Selection",
            },
            {
                "<leader>ab",
                function()
                    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("ggVG", true, true, true), "", false)
                    vim.schedule(
                        function()
                            require("sidekick.cli").send({
                                msg = "{selection}",
                                name = default_ai_cli,
                            })
                        end
                    )
                end,
                mode = { "x", "n" },
                desc = "Send Buffer",
            },
            {
                "<leader>ap",
                function() require("sidekick.cli").prompt() end,
                mode = { "n", "x" },
                desc = "Sidekick Select Prompt",
            },
        },
    },
}
