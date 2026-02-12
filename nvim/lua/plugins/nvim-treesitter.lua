---@module 'lazy'
---@type LazySpec
return {
    {
        -- "https://github.com/nvim-treesitter/nvim-treesitter-context",
        "https://github.com/bvaughnsulit/nvim-treesitter-context",
        branch = "bvs",
        -- dev = true,
        event = "VeryLazy",
        ---@module 'treesitter-context'
        ---@type TSContext.UserConfig
        opts = {
            max_lines = 0,
            multline_threshold = 99,
            flatten_multiline = true,
            multiwindow = true,
        },
        keys = function(plugin)
            local default_max_lines = plugin.opts.max_lines
            local base_config = vim.deepcopy(plugin.opts or {})

            return {
                { "<leader>tC", "<cmd>TSContextToggle<cr>" },
                {
                    "<leader>tc",
                    function()
                        if base_config.max_lines == default_max_lines then
                            base_config.max_lines = "10%"
                            require("treesitter-context").setup(base_config)
                        else
                            base_config.max_lines = default_max_lines
                            require("treesitter-context").setup(base_config)
                        end
                    end,
                    desc = "Toggle Treesitter Context Max Lines",
                },
            }
        end,
    },
    {
        "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
        ---@module 'nvim-treesitter-textobjects'
        ---@type TSTextObjects.UserConfig
        opts = {
            select = {
                lookahead = true,
            },
            move = {
                set_jumps = true,
            },
        },
        keys = function()
            local keys = {}

            ---@type { [1]: string, [2]: "start" | "end", previous: string, next: string }[]
            local move_maps = {
                { "@parameter.inner", "start", previous = "[a", next = "]a" },
                { "@function.outer", "start", previous = "[m", next = "]m" },
                { "@block.outer", "start", previous = "[[", next = "]]" },
                { "@comment.outer", "start", previous = "[/", next = "]/" },
                { "@function.outer", "end", previous = "[M", next = "]M" },
                { "@block.outer", "end", previous = "[{", next = "]}" },
            }

            for _, move in pairs(move_maps) do
                table.insert(keys, {
                    move.previous,
                    function()
                        require("nvim-treesitter-textobjects.move")["goto_previous_" .. move[2]](move[1], "textobjects")
                    end,
                    mode = { "n", "x", "o" },
                    desc = "Previous " .. move[1] .. " " .. move[2],
                })
            end

            for _, move in pairs(move_maps) do
                table.insert(keys, {
                    move.next,
                    function()
                        require("nvim-treesitter-textobjects.move")["goto_next_" .. move[2]](move[1], "textobjects")
                    end,
                    mode = { "n", "x", "o" },
                    desc = "Next " .. move[1] .. " " .. move[2],
                })
            end

            local swap_maps = {
                { "@parameter.inner", previous = "<leader>[a", next = "<leader>]a" },
            }

            for _, swap in pairs(swap_maps) do
                table.insert(keys, {
                    swap.previous,
                    function() require("nvim-treesitter-textobjects.swap").swap_previous(swap[1]) end,
                    mode = { "n" },
                    desc = "Swap previous " .. swap[1],
                })
            end

            for _, swap in pairs(swap_maps) do
                table.insert(keys, {
                    swap.next,
                    function() require("nvim-treesitter-textobjects.swap").swap_next(swap[1]) end,
                    mode = { "n" },
                    desc = "Swap next " .. swap[1],
                })
            end

            return keys
        end,
    },
    {
        "https://github.com/nvim-treesitter/nvim-treesitter",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            local filetypes = {
                "bash",
                "c",
                "diff",
                "html",
                "javascript",
                "jsdoc",
                "json",
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
            }
            require("nvim-treesitter").install(filetypes)
            vim.api.nvim_create_autocmd("FileType", {
                pattern = filetypes,
                callback = function()
                    vim.treesitter.start()
                    vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
                    vim.wo[0][0].foldmethod = "expr"
                    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end,
            })
        end,
    },
}
