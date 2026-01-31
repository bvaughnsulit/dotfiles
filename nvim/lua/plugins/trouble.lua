---@module 'lazy'
---@type LazySpec
return {
    "https://github.com/folke/trouble.nvim",
    event = "BufReadPost",
    dependencies = "https://github.com/nvim-tree/nvim-web-devicons",
    ---@module 'trouble'
    ---@type trouble.Config
    opts = {},
    keys = {},
}
