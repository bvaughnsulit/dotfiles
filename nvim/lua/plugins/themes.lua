local utils = require("config.utils")
local is_system_dark_mode = utils.is_system_dark_mode()

local default_light_theme = "github_light_colorblind"
local default_dark_theme = "tokyonight-moon"

utils.create_cmd_and_map("DarkMode", nil, function() vim.cmd("colorscheme " .. default_dark_theme) end)
utils.create_cmd_and_map("LightMode", nil, function() vim.cmd("colorscheme " .. default_light_theme) end)
utils.create_cmd_and_map("ToggleLightDarkMode", nil, function()
    if vim.g.colors_name == default_light_theme then
        vim.cmd("colorscheme " .. default_dark_theme)
    else
        vim.cmd("colorscheme " .. default_light_theme)
    end
end)

return {
    {
        "projekt0n/github-nvim-theme",
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
            if not is_system_dark_mode and default_light_theme == "github_light_colorblind" then
                vim.cmd("colorscheme github_light_colorblind")
            end
            vim.cmd([[hi! default link Delimiter Special]])
        end,
    },
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("tokyonight").setup({
                styles = {
                    keywords = { italic = false },
                },
            })
            if is_system_dark_mode and default_dark_theme == "tokyonight-moon" then
                vim.cmd("colorscheme tokyonight-moon")
            end
        end,
    },
    {
        "catppuccin/nvim",
        lazy = false,
        priority = 1000,
        name = "catppuccin",
        config = function()
            require("catppuccin").setup({
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
            })
        end,
    },
}
