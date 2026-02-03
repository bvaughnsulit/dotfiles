---@module 'lazy'
---@type LazySpec
return {
    {
        "https://github.com/ibhagwan/fzf-lua",
        event = "VeryLazy",
        enabled = true,
        dependencies = {
            "https://github.com/nvim-tree/nvim-web-devicons",
        },
        ---@module "fzf-lua"
        ---@type fzf-lua.Config|{}
        ---@diagnostic disable: missing-fields
        opts = {
            fzf_opts = {
                ["--cycle"] = true,
            },
            winopts = {
                height = 0.95,
                width = 0.95,
                preview = {
                    flip_columns = 200,
                },
            },
        },
        ---@diagnostic enable: missing-fields
        config = function(_, opts)
            local fzf_lua = require("fzf-lua")
            fzf_lua.setup(opts)

            require("config.pickers").register_picker("fzf-lua", {
                find_files = function() fzf_lua.files() end,
                buffers = function() fzf_lua.buffers() end,
                live_grep = function() fzf_lua.live_grep() end,
                lsp_definitions = function() fzf_lua.lsp_definitions() end,
                lsp_references = function() fzf_lua.lsp_references() end,
                lsp_type_definitions = function() fzf_lua.lsp_typedefs() end,
                keymaps = function() fzf_lua.keymaps() end,
                help_tags = function() fzf_lua.helptags() end,
                commands = function() fzf_lua.commands() end,
                buffer_fuzzy = function() fzf_lua.lgrep_curbuf() end,
                pickers = function() fzf_lua.builtin() end,
                resume = function() fzf_lua.resume() end,
            })

            vim.keymap.set("n", "<leader>ppf", ":FzfLua<cr>", { desc = "Fzf Lua Pickers" })
        end,
    },
}
