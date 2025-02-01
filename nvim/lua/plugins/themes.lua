local utils = require('config.utils')
local is_system_dark_mode = utils.is_system_dark_mode()

return {
  {
    'projekt0n/github-nvim-theme',
    lazy = false,
    dev = false,
    priority = 1000,
    config = function()
      require('github-theme').setup({})
      if not is_system_dark_mode then vim.cmd('colorscheme github_light_colorblind') end
      vim.cmd([[hi! default link Delimiter Special]])
    end,
  },
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('tokyonight').setup({
        styles = {
          comments = { italic = false },
          keywords = { italic = false },
        },
      })
      if is_system_dark_mode then vim.cmd('colorscheme tokyonight') end
    end,
  },
  {
    'catppuccin/nvim',
    lazy = false,
    priority = 1000,
    name = 'catppuccin',
    config = function()
      require('catppuccin').setup({
        dim_inactive = {
          enabled = true,
          shade = 'dark',
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
