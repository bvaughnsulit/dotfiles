---@module 'lazy'
---@type LazySpec
return {
    {
        "https://github.com/nvim-treesitter/playground",
        cmd = "TSPlaygroundToggle",
    },
    {
        "https://github.com/nvim-treesitter/nvim-treesitter-context",
        event = "VeryLazy",
        ---@module 'treesitter-context'
        ---@type TSContext.UserConfig
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
        "https://github.com/nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        version = false,
        dependencies = {
            "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
            config = function() return nil end,
        },
        cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
        keys = {
            -- { "<c-space>", false },
            -- { "<bs>", false },
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
                ensure_installed = {
                    "bash",
                    "c",
                    "diff",
                    "html",
                    "javascript",
                    "jsdoc",
                    "json",
                    "jsonc",
                    "lua",
                    "luadoc",
                    "luap",
                    "markdown",
                    "markdown_inline",
                    "printf",
                    "python",
                    "query",
                    "regex",
                    "toml",
                    "tsx",
                    "typescript",
                    "vim",
                    "vimdoc",
                    "xml",
                    "yaml",
                },
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
        config = function(_, opts) require("nvim-treesitter.configs").setup(opts) end,
    },
    {
        "https://github.com/stevearc/aerial.nvim",
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
