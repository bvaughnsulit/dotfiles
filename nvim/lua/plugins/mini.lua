local utils = require("config.utils")

return {
    {
        "echasnovski/mini.nvim",
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
                symbol = "▏",
            })
            require("mini.cursorword").setup({})
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
            })

            local trailspace = require("mini.trailspace")
            trailspace.setup({})

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
        end,
        keys = {
            { "<A-j>", nil, mode = { "n", "v" } },
            { "<A-k>", nil, mode = { "n", "v" } },
        },
    },
}
