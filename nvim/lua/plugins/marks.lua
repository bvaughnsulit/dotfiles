---@module 'lazy'
---@type LazySpec
return {
    "https://github.com/chentoast/marks.nvim",
    event = "VeryLazy",
    opts = {
        mappings = {
            set = "m",
            set_next = false,
            toggle = "m,",
            next = false,
            prev = false,
            preview = "m:",
            next_bookmark = "m}",
            prev_bookmark = "m{",
            delete = "dm",
            delete_line = "dm-",
            delete_bookmark = "dm=",
            delete_buf = "dm<space>",
        },
    },
    keys = {
        {
            "]'",
            function()
                require("marks").next()
                vim.cmd("normal! m'") -- TODO this can be better
            end,
            { desc = "Jump to next mark" },
        },
        {
            "['",
            function()
                require("marks").prev()
                vim.cmd("normal! m'")
            end,
            { desc = "Jump to previous mark" },
        },
    },
}
