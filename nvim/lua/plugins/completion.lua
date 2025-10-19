return {
    {
        "saghen/blink.cmp",
        dependencies = "rafamadriz/friendly-snippets",
        enabled = true,
        version = "1.*",

        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            keymap = {
                preset = "enter",
                ["<C-u>"] = { "scroll_documentation_up", "fallback" },
                ["<C-d>"] = { "scroll_documentation_down", "fallback" },
            },
            appearance = {
                use_nvim_cmp_as_default = true,
                nerd_font_variant = "mono",
            },
            sources = {
                default = { "lsp", "path", "snippets", "buffer" },
            },
            completion = {
                menu = {
                    border = "single",
                    draw = {
                        columns = {
                            { "label", "label_description", gap = 1 },
                            { "kind" },
                        },
                    },
                },
                trigger = { show_on_backspace = true },
                list = {
                    selection = {
                        preselect = false,
                        auto_insert = true,
                    },
                },
                documentation = {
                    window = { border = "single" },
                    auto_show = true,
                    auto_show_delay_ms = 300,
                },
            },
            signature = {
                window = { border = "single" },
                enabled = true,
            },
            cmdline = {
                completion = {
                    list = { selection = { preselect = false } },
                    ghost_text = { enabled = false },
                    menu = {
                        auto_show = true,
                    },
                },
            },
        },
        opts_extend = { "sources.default" },
    },
    {
        "https://github.com/zbirenbaum/copilot.lua",
        event = "InsertEnter",
        config = function()
            --- @type CopilotConfig
            require("copilot").setup({
                panel = { enabled = false },
                enabled = true,
                suggestion = {
                    auto_trigger = true,
                    debounce = 10,
                    keymap = {
                        accept = false,
                        accept_word = "<M-Tab>",
                        accept_line = false,
                        next = "<M-]>",
                        prev = "<M-[>",
                        dismiss = "<C-]>",
                    },
                },
                filetypes = {},
                logger = {
                    -- file_log_level = vim.log.levels.TRACE,
                },
                copilot_model = "",
            })
            vim.keymap.set("i", "<Tab>", function()
                if require("copilot.suggestion").is_visible() then
                    require("copilot.suggestion").accept_line()
                else
                    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
                end
            end)
        end,
    },
}
