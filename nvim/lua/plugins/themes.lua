local utils = require("config.utils")
local is_system_dark_mode = utils.is_system_dark_mode()

local default_light_theme = "github_light_colorblind"
local default_dark_theme = "tokyonight-moon"

local set_dark_mode = function()
    vim.o.background = "dark"
    vim.cmd("colorscheme " .. default_dark_theme)
end

local set_light_mode = function()
    vim.o.background = "light"
    vim.cmd("colorscheme " .. default_light_theme)
end

_G.set_dark_mode = set_dark_mode
_G.set_light_mode = set_light_mode

utils.create_cmd_and_map("ToggleLightDarkMode", nil, function()
    if vim.g.colors_name == default_light_theme then
        set_dark_mode()
    else
        set_light_mode()
    end
end)

---@module 'lazy'
---@type LazySpec
return {
    {
        "https://github.com/projekt0n/github-nvim-theme",
        lazy = false,
        dev = false,
        priority = 1000,
        ---@type GhTheme.Config
        opts = {
            options = {
                modules = {
                    dapui = true,
                    diagnostic = true,
                    fzf = true,
                    gitsigns = true,
                    indent_blankline = true,
                    lsp_trouble = true,
                    mini = true,
                    native_lsp = true,
                    neotree = true,
                    notify = true,
                    telescope = true,
                    treesitter = true,
                    treesitter_context = true,
                    whichkey = true,
                },
            },
        },
        config = function(_, opts)
            require("github-theme").setup(opts)
            if not is_system_dark_mode and default_light_theme == "github_light_colorblind" then set_light_mode() end
            vim.cmd([[hi! default link Delimiter Special]])
        end,
    },
    {
        "https://github.com/folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        ---@type tokyonight.Config
        ---@diagnostic disable: missing-fields
        opts = {
            styles = {
                keywords = { italic = false },
            },
        },
        ---@diagnostic enable: missing-fields
        config = function(_, opts)
            require("tokyonight").setup(opts)
            if is_system_dark_mode and default_dark_theme == "tokyonight-moon" then set_dark_mode() end
        end,
    },
    {
        "https://github.com/catppuccin/nvim",
        lazy = false,
        priority = 1000,
        name = "catppuccin",
        opts = {
            dim_inactive = {
                enabled = true,
                shade = "dark",
                percentage = 0.15,
            },
            no_italic = true,
            integrations = {
                telescope = { enabled = true },
                lsp_trouble = true,
                treesitter = true,
                treesitter_context = true,
                notify = true,
                dap = true,
                cmp = true,
                gitsigns = true,
                leap = true,
                mini = true,
                neotree = true,
                neotest = true,
                illuminate = true,
            },
        },
    },
}
