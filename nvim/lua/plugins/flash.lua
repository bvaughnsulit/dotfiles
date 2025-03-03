return {
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        enabled = true,
        opts = {
            label = {
                uppercase = false,
            },
            modes = {
                search = {
                    enabled = false,
                },
                char = {
                    config = function(opts) opts.jump_labels = vim.v.count == 0 and not vim.fn.mode(true):find("o") end,
                },
            },
            prompt = { enabled = false },
        },
        keys = {
            {
                "s",
                mode = { "n", "x", "o" },
                function()
                    -- default options: exact mode, multi window, all directions, with a backdrop
                    require("flash").jump()
                end,
                desc = "Flash",
            },
            {
                "S",
                mode = { "n", "o", "x" },
                function() require("flash").treesitter() end,
                desc = "Flash Treesitter",
            },
            {
                "r",
                mode = "o",
                function() require("flash").remote() end,
                desc = "Remote Flash",
            },
            {
                "R",
                mode = { "o", "x" },
                function() require("flash").treesitter_search() end,
                desc = "Flash Treesitter Search",
            },
            {
                "<c-s>",
                mode = { "c" },
                function() require("flash").toggle() end,
                desc = "Toggle Flash Search",
            },
        },
    },
}
