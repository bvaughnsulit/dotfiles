local utils = require("config.utils")

---@module 'lazy'
---@type LazySpec
return {
    {
        "https://github.com/echasnovski/mini.nvim",
        version = false,
        event = "VeryLazy",
        config = function()
            require("mini.indentscope").setup({
                draw = {
                    animation = require("mini.indentscope").gen_animation.none(),
                },
                options = {
                    indent_at_cursor = true,
                    try_as_border = true,
                },
                mappings = {},
                symbol = "▏",
            })
            require("mini.cursorword").setup({})
            require("mini.align").setup({})
            require("mini.icons").setup({})
            require("mini.surround").setup({
                mappings = {
                    add = "gsa", -- Add surrounding in Normal and Visual modes
                    delete = "gsd", -- Delete surrounding
                    find = "gsf", -- Find surrounding (to the right)
                    find_left = "gsF", -- Find surrounding (to the left)
                    highlight = "gsh", -- Highlight surrounding
                    replace = "gsr", -- Replace surrounding
                    update_n_lines = "gsn", -- Update `n_lines`
                    suffix_last = "l", -- Suffix to search with "prev" method
                    suffix_next = "n", -- Suffix to search with "next" method
                },
            })
            require("mini.ai").setup({})
            require("mini.move").setup({})
            require("mini.operators").setup({
                replace = { prefix = "gp" },
                exchange = { prefix = "gX" },
            })
            require("mini.bracketed").setup({
                conflict = { suffix = "x", options = { wrap = false } },

                indent = { suffix = "" },
                jump = { suffix = "" },
                comment = { suffix = "" },
                diagnostic = { suffix = "" },
                treesitter = { suffix = "" },
                location = { suffix = "" },
                quickfix = { suffix = "" },
                file = { suffix = "" },
                oldfile = { suffix = "" },
                buffer = { suffix = "" },
                undo = { suffix = "" },
                window = { suffix = "" },
                yank = { suffix = "" },
            })

            local trailspace = require("mini.trailspace")
            trailspace.setup({})
            vim.g.minitrailspace_disable = true

            vim.api.nvim_create_autocmd("BufWritePre", {
                group = vim.api.nvim_create_augroup("Mini", {}),
                callback = function(event)
                    if vim.g.minitrailspace_disable then return end
                    trailspace.trim()
                end,
            })

            utils.create_cmd_and_map("ToggleTrailspace", nil, function()
                vim.g.minitrailspace_disable = not vim.g.minitrailspace_disable
                vim.notify("MiniTrailspace is " .. (vim.g.minitrailspace_disable and "disabled" or "enabled"))
            end, "Toggle trailing whitespace highlighting")

            local ui_select_orig = vim.ui.select
            local mini_pick = require("mini.pick")
            mini_pick.setup({})
            vim.ui.select = ui_select_orig
            require("config.pickers").register_picker("mini", {
                live_grep = function() mini_pick.builtin.grep_live({}) end,
            })
        end,
        keys = {
            { "<A-j>", nil, mode = { "n", "v" } },
            { "<A-k>", nil, mode = { "n", "v" } },
            { "<A-o>", function() require("mini.bracketed").jump("backward", { wrap = false }) end },
            { "<A-i>", function() require("mini.bracketed").jump("forward", { wrap = false }) end },
        },
    },
}
