---@module 'lazy'
---@type LazySpec
return {
    {
        "https://github.com/saghen/blink.cmp",
        dependencies = "https://github.com/rafamadriz/friendly-snippets",
        event = "VeryLazy",
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
                default = { "lsp", "lazydev", "path", "snippets", "buffer" },
                per_filetype = {
                    sql = { "snippets", "dadbod", "buffer" },
                },
                providers = {
                    dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
                    lazydev = { name = "LazyDev", module = "lazydev.integrations.blink" },
                    buffer = {
                        opts = {
                            get_bufnrs = function()
                                return vim.iter(vim.api.nvim_list_wins())
                                    :map(function(win) return vim.api.nvim_win_get_buf(win) end)
                                    :filter(
                                        function(buf)
                                            return vim.bo[buf].buftype ~= "nofile"
                                                and vim.bo[buf].buftype ~= "terminal"
                                                and not vim.tbl_contains({
                                                    "dap-repl",
                                                    "neo-tree",
                                                    "aerial",
                                                    "dapui_console",
                                                    "dapui_scopes",
                                                    "dapui_watches",
                                                    "dapui_stacks",
                                                }, vim.bo[buf].filetype)
                                        end
                                    )
                                    :totable()
                            end,
                        },
                    },
                },
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
        ---@diagnostic disable: missing-fields
        ---@module 'copilot'
        ---@type CopilotConfig
        opts = {
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
            filetypes = {
                markdown = true,
            },
            logger = {
                -- file_log_level = vim.log.levels.TRACE,
            },
            copilot_model = "",
            should_attach = function(buf)
                return vim.bo[buf].buflisted
                    and vim.bo[buf].buftype == ""
                    and not vim.tbl_contains({
                        "dap-repl",
                        "neo-tree",
                        "aerial",
                        "dapui_console",
                        "dapui_scopes",
                        "dapui_watches",
                        "dapui_stacks",
                    }, vim.bo[buf].filetype)
            end,
        },
        --@diagnostic enable: missing-fields
        config = function(_, opts)
            require("copilot").setup(opts)
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
