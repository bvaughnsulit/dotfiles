return {
  {
    'projekt0n/github-nvim-theme',
    lazy = false,
    priority = 1001,
    config = function() vim.cmd('colorscheme github_light_colorblind') end,
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
      'projekt0n/github-nvim-theme',
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
        'wildcharm',
        --other
        'randomhue',
        'material',
        'tokyonight',
        'catppuccin',
        'tokyonight-day',
        --nightfox
        'terafox',
        'dawnfox',
        'dayfox',
        -- 'nordfox',
        'everforest',
        'github_dark_tritanopia',
        'github_light_tritanopia',
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
        ['everforest-light'] = {
          setup = function()
            vim.opt.background = 'light'
            vim.g.everforest_background = 'medium'
            vim.cmd('colorscheme everforest')
          end,
        },
      },
    },
  },
}
