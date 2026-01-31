---@module 'lazy'
---@type LazySpec
return {
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
