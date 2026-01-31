---@module 'lazy'
---@type LazySpec
return {
    {
        "https://github.com/ibhagwan/fzf-lua",
        event = "VeryLazy",
        enabled = false,
        dependencies = {
            "https://github.com/nvim-tree/nvim-web-devicons",
        },
        ---@module "fzf-lua"
        ---@type fzf-lua.Config|{}
        ---@diagnostic disable: missing-fields
        opts = {},
        ---@diagnostic enable: missing-fields
        config = function(_, opts)
            local fzf_lua = require("fzf-lua")
            fzf_lua.setup(opts)

            require("config.pickers").register_picker("fzf-lua", {
                live_grep = function() fzf_lua.live_grep() end,
            })

            vim.keymap.set("n", "<leader>ppf", ":FzfLua<cr>", { desc = "Fzf Lua Pickers" })
        end,
    },
}
