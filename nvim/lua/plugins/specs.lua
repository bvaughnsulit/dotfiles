return {
  -- other themes
  -- 'marko-cerovac/material.nvim',
  -- 'https://gitlab.com/__tpb/monokai-pro.nvim',
  -- 'sainnhe/gruvbox-material',
  -- 'ishan9299/nvim-solarized-lua',
  -- 'shaunsingh/solarized.nvim',
  -- { 'catppuccin/nvim', name = 'catppuccin' },
  -- 'folke/tokyonight.nvim',
  -- 'EdenEast/nightfox.nvim',
  -- 'ofirgall/ofirkai.nvim',
  -- 'nyoom-engineering/oxocarbon.nvim',

  'tpope/vim-fugitive',
  'JoosepAlviste/nvim-ts-context-commentstring',
  {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup {
        pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
      }
    end,
    event = 'VeryLazy',
  },

  {
    'windwp/nvim-autopairs',
    config = function()
      require('nvim-autopairs').setup {}
    end,
  },
  { 'eandrju/cellular-automaton.nvim', cmd = 'CellularAutomaton' },
  {
    'rmagatti/auto-session',
    lazy = false,
    config = function()
      require('auto-session').setup {
        log_level = 'error',
        auto_session_suppress_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
      }
    end,
  },
  {
    'dstein64/vim-startuptime',
    cmd = 'StartupTime',
    config = function()
      vim.g.startuptime_tries = 10
    end,
  },
}
