---@module 'lazy'
---@type LazySpec
return {
    "https://github.com/numToStr/Navigator.nvim",
    -- NOTE: could load on keys instead
    event = "VeryLazy",
    opts = {
        disable_on_zoom = true,
    },
    keys = {
        { "<C-h>", "<CMD>NavigatorLeft<CR>", mode = { "n", "t" } },
        { "<C-w>h", "<CMD>NavigatorLeft<CR>", mode = { "n", "t" } },
        { "<C-l>", "<CMD>NavigatorRight<CR>", mode = { "n", "t" } },
        { "<C-w>l", "<CMD>NavigatorRight<CR>", mode = { "n", "t" } },
        { "<C-k>", "<CMD>NavigatorUp<CR>", mode = { "n", "t" } },
        { "<C-w>k", "<CMD>NavigatorUp<CR>", mode = { "n", "t" } },
        { "<C-j>", "<CMD>NavigatorDown<CR>", mode = { "n", "t" } },
        { "<C-w>j", "<CMD>NavigatorDown<CR>", mode = { "n", "t" } },
    },
}
