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
  {
    'folke/todo-comments.nvim',
    dependencies = 'nvim-lua/plenary.nvim',
    cmd = { 'TodoTrouble', 'TodoTelescope' },
    event = 'BufReadPost',
    config = function()
      require('todo-comments').setup {
        signs = false,
        -- pattern = [[\b(KEYWORDS)\b]], -- doesn't work :-(
        merge_keywords = false,
        keywords = {
          FIX = {
            icon = ' ', -- icon used for the sign, and in search results
            color = 'error', -- can be a hex color, or a named color (see below)
            alt = { 'FIXME', 'BUG', 'FIXIT', 'ISSUE' }, -- a set of other keywords that all map to this FIX keywords
          },
          TODO = { icon = ' ', color = 'info' },
          HACK = { icon = ' ', color = 'warning' },
          -- WARN = { icon = ' ', color = 'warning', alt = { 'WARNING', 'XXX' } },
          PERF = { icon = ' ', alt = { 'OPTIM', 'PERFORMANCE', 'OPTIMIZE' } },
          NOTE = { icon = ' ', color = 'hint', alt = { 'INFO' } },
          TEST = { icon = ' ', color = 'test', alt = { 'TESTING', 'PASSED', 'FAILED' } },
        },
        highlight = {
          keyword = "bg",
          after = "",
        }
      }
    end,
    -- stylua: ignore
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
    },
  },
}
