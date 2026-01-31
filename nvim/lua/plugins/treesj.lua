---@module 'lazy'
---@type LazySpec
return {
    "https://github.com/Wansmer/treesj",
    dependencies = { "https://github.com/nvim-treesitter/nvim-treesitter" },
    event = "BufReadPost",
    opts = {
        use_default_keymaps = false,
        check_syntax_error = true,
        max_join_length = math.huge,
        cursor_behavior = "hold",
        notify = true,
    },
    keys = {
        { "<leader><cr>", "<cmd>TSJToggle<cr>" },
    },
}
