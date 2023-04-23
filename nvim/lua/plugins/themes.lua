return {
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1001,
    config = function() vim.cmd('colorscheme tokyonight-moon') end,
  },
  {
    'bvaughnsulit/theme-select.nvim',
    dev = true,
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
      -- 'marko-cerovac/material.nvim',
      -- { 'catppuccin/nvim', name = 'catppuccin' },
      'sainnhe/gruvbox-material',
      'folke/tokyonight.nvim',
      'EdenEast/nightfox.nvim',
    },
    opts = {
      exclude = {
        --defaults
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
        --tokyonight
        'tokyonight',
        -- 'tokyonight-day',
        --nightfox
        'terafox',
        -- 'dawnfox',
        -- 'dayfox',
        -- 'nordfox',
      },
      add = {
        -- ['material-deep-ocean'] = {
        --   setup = function()
        --     vim.g.material_style = 'deep ocean'
        --     vim.cmd('colorscheme material')
        --   end,
        -- },
        -- ['material-palenight'] = {
        --   setup = function()
        --     vim.g.material_style = 'palenight'
        --     vim.cmd('colorscheme material')
        --   end,
        -- },
      },
    },
  },
}
