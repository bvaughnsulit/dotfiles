return {
    "numToStr/Navigator.nvim",
    -- NOTE: could load on keys instead
    event = "VeryLazy",
    config = function()
        require("Navigator").setup({ disable_on_zoom = true })

        vim.keymap.set("n", "<C-h>", "<CMD>NavigatorLeft<CR>")
        vim.keymap.set("n", "<C-w>h", "<CMD>NavigatorLeft<CR>")

        vim.keymap.set("n", "<C-l>", "<CMD>NavigatorRight<CR>")
        vim.keymap.set("n", "<C-w>l", "<CMD>NavigatorRight<CR>")

        vim.keymap.set("n", "<C-k>", "<CMD>NavigatorUp<CR>")
        vim.keymap.set("n", "<C-w>k", "<CMD>NavigatorUp<CR>")

        vim.keymap.set("n", "<C-j>", "<CMD>NavigatorDown<CR>")
        vim.keymap.set("n", "<C-w>j", "<CMD>NavigatorDown<CR>")
    end,
}
