---@module 'lazy'
---@type LazySpec
return {
    "https://github.com/numToStr/Navigator.nvim",
    -- NOTE: could load on keys instead
    event = "VeryLazy",
    config = function()
        require("Navigator").setup({ disable_on_zoom = true })

        vim.keymap.set({ "n", "t" }, "<C-h>", "<CMD>NavigatorLeft<CR>")
        vim.keymap.set({ "n", "t" }, "<C-w>h", "<CMD>NavigatorLeft<CR>")

        vim.keymap.set({ "n", "t" }, "<C-l>", "<CMD>NavigatorRight<CR>")
        vim.keymap.set({ "n", "t" }, "<C-w>l", "<CMD>NavigatorRight<CR>")

        vim.keymap.set({ "n", "t" }, "<C-k>", "<CMD>NavigatorUp<CR>")
        vim.keymap.set({ "n", "t" }, "<C-w>k", "<CMD>NavigatorUp<CR>")

        vim.keymap.set({ "n", "t" }, "<C-j>", "<CMD>NavigatorDown<CR>")
        vim.keymap.set({ "n", "t" }, "<C-w>j", "<CMD>NavigatorDown<CR>")
    end,
}
