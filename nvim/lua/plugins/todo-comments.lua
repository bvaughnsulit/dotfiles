---@module 'lazy'
---@type LazySpec
return {
    "https://github.com/folke/todo-comments.nvim",
    dependencies = "https://github.com/nvim-lua/plenary.nvim",
    cmd = { "TodoTrouble", "TodoTelescope" },
    event = "BufReadPost",
    opts = {
        signs = false,
        -- pattern = [[\b(KEYWORDS)\b]], -- doesn't work :-(
        merge_keywords = false,
        keywords = {
            FIX = {
                icon = " ", -- icon used for the sign, and in search results
                color = "error", -- can be a hex color, or a named color (see below)
                alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
            },
            TODO = { icon = " ", color = "info" },
            HACK = { icon = " ", color = "warning" },
            -- WARN = { icon = ' ', color = 'warning', alt = { 'WARNING', 'XXX' } },
            PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
            NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
            TEST = { icon = " ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
        },
        highlight = {
            keyword = "bg",
            after = "",
        },
    },
    keys = {
        -- { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
        -- { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
    },
}
