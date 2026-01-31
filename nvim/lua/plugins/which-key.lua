---@type LazySpec
return {
    "https://github.com/folke/which-key.nvim",
    event = "VeryLazy",
    ---@type wk.Opts
    ---@diagnostic disable-next-line: missing-fields
    opts = {
        preset = "classic",
        delay = function(ctx) return 500 end,
        ---@type wk.Spec
        spec = {
            { "<leader>", group = "leader" },
            { "<leader>a", group = "AI" },
            { "<leader>c", group = "code/quickfix" },
            { "<leader>d", group = "debug" },
            { "<leader>e", group = "explorer" },
            { "<leader>g", group = "git" },
            { "<leader>h", group = "hunk" },
            { "<leader>k", group = "keymaps" },
            { "<leader>p", group = "picker" },
            { "<leader>q", group = "quit" },
            { "<leader>t", group = "toggle" },
            { "<leader>!", group = "terminal" },
            { "<leader>/", group = "search" },
            { "<leader>\\", group = "terminal" },

            { "<leader>r", hidden = true },
        },
    },
    keys = {
        {
            "<leader>kk",
            function()
                require("which-key").show({
                    loop = true,
                })
            end,
            desc = "Show which-key menu",
        },
    },
}
