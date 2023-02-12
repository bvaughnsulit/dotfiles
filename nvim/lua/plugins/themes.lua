return {
  {
    'bvaughnsulit/theme-select.nvim',
    lazy = false,
    priority = 999,
    cond = function()
      if vim.g.set_scheme == nil then
        return false
      else
        return true
      end
    end,
    dependencies = {
      'marko-cerovac/material.nvim',
      'https://gitlab.com/__tpb/monokai-pro.nvim',
      'sainnhe/gruvbox-material',
      'ishan9299/nvim-solarized-lua',
      'shaunsingh/solarized.nvim',
      { 'catppuccin/nvim', name = 'catppuccin' },
      'folke/tokyonight.nvim',
      'EdenEast/nightfox.nvim',
      'ofirgall/ofirkai.nvim',
      'nyoom-engineering/oxocarbon.nvim',
    },
    opts = {
      exclude = {
        'ron',
        'blue',
        'darkblue',
        'default',
        'delek',
        'desert',
        'elflord',
        'evening',
        'habamax',
        'industry',
        'koehler',
        'lunaperche',
        'morning',
        'murphy',
        'pablo',
        'peachpuff',
        'quiet',
        'ron',
        'shine',
        'slate',
        'torte',
        'zellner',
      },
      add = {
        ['material-deep-ocean'] = {
          setup = function()
            vim.g.material_style = 'deep ocean'
            vim.cmd 'colorscheme material'
          end,
        },
        ['material-palenight'] = {
          setup = function()
            vim.g.material_style = 'palenight'
            vim.cmd 'colorscheme material'
          end,
        },
      },
    },
  },
}
