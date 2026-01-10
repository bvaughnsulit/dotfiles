return {
    {
        "nvim-treesitter/playground",
        cmd = "TSPlaygroundToggle",
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        event = "VeryLazy",
        opts = {
            max_lines = "40%",
            multline_threshold = 3,
            ensure_installed = { "dart" },
            multiwindow = true,
        },
        keys = {
            { "<leader>tc", "<cmd>TSContextToggle<cr>" },
        },
    },
    {
        "nvim-treesitter/nvim-treesitter",
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
            config = function() return nil end,
        },
        keys = {
            { "<c-space>", false },
            { "<bs>", false },
        },
        opts = function()
            return {
                highlight = { enable = true },
                indent = { enable = true },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "gnn",
                        node_incremental = "<c-n>",
                        scope_incremental = "grc",
                        node_decremental = "<c-m>",
                    },
                },
                ignore_install = { "angular", "groovy" },
                textobjects = {
                    move = {
                        enable = true,
                        set_jumps = true,
                        goto_previous_start = {
                            ["[a"] = "@parameter.inner",
                            ["[m"] = "@function.outer",
                            ["[["] = "@block.outer",
                            ["[/"] = "@comment.outer",
                        },
                        goto_next_start = {
                            ["]a"] = "@parameter.inner",
                            ["]m"] = "@function.outer",
                            ["]]"] = "@block.outer",
                            ["]/"] = "@comment.outer",
                        },
                        goto_previous_end = {
                            ["[M"] = "@function.outer",
                            ["[]"] = "@block.outer",
                        },
                        goto_next_end = {
                            ["]M"] = "@function.outer",
                            ["]["] = "@block.outer",
                        },
                    },
                    swap = {
                        enable = true,
                        -- swap_next = {
                        --     ["<leader>a"] = "@parameter.inner",
                        -- },
                        -- swap_previous = {
                        --     ["<leader>A"] = "@parameter.inner",
                        -- },
                    },
                    lsp_interop = {
                        enable = true,
                        border = "none",
                        peek_definition_code = {
                            ["<leader>df"] = "@function.outer",
                            ["<leader>dF"] = "@class.outer",
                        },
                    },
                },
            }
        end,
    },
    {
        "stevearc/aerial.nvim",
        event = "VeryLazy",
        keys = {
            { "<leader>es", "<cmd>AerialToggle<cr>" },
        },
        opts = {
            layout = {
                width = 0.35,
                max_width = 0.5,
            },
            highlight_on_hover = true,
            highlight_on_jump = 300,
            autojump = true,
            close_on_select = true,
        },
    },
}
