return {
  {
    'rebelot/kanagawa.nvim',
    lazy = false,
    priority = 1001,
    config = function() vim.cmd('colorscheme kanagawa-wave') end,
  },
  {
    'bvaughnsulit/theme-select.nvim',
    dev = false,
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
      'folke/tokyonight.nvim',
      'marko-cerovac/material.nvim',
      'sainnhe/gruvbox-material',
      'folke/tokyonight.nvim',
      'EdenEast/nightfox.nvim',
      'rebelot/kanagawa.nvim',
      'sainnhe/everforest',
      'loctvl842/monokai-pro.nvim',
      'maxmx03/fluoromachine.nvim',
      {
        'catppuccin/nvim',
        name = 'catppuccin',
        config = function()
          require('catppuccin').setup({
            integrations = {
              telescope = true,
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
        'sorbet',
        'zaibatsu',
        'retrobox',
        --other
        'material',
        'tokyonight',
        'catppuccin',
        -- 'tokyonight-day',
        --nightfox
        'terafox',
        -- 'dawnfox',
        -- 'dayfox',
        -- 'nordfox',
      },
      add = {
        ['material-deep-ocean'] = {
          setup = function()
            vim.g.material_style = 'deep ocean'
            vim.cmd('colorscheme material')
          end,
        },
        ['material-palenight'] = {
          setup = function()
            vim.g.material_style = 'palenight'
            vim.cmd('colorscheme material')
          end,
        },
      },
    },
  },
}
