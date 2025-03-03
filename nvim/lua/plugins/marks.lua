return {
    "chentoast/marks.nvim",
    event = "VeryLazy",
    config = true,
    keys = {
        {
            "]'",
            '<cmd>lua require("marks").next()<CR>',
            { desc = "Jump to next mark" },
        },
        {
            "['",
            '<cmd>lua require("marks").prev()<CR>',
            { desc = "Jump to previous mark" },
        },
        {
            "<leader>mm",
            mode = { "n" },
            function()
                require("marks").mark_state:all_to_list()
                vim.cmd("lopen")
            end,
            { desc = "Toggle mark visual" },
        },
    },
}
