return {
  -- disabled specs
  { 'akinsho/bufferline.nvim', enabled = false },
  { 'windwp/nvim-ts-autotag', enabled = false },
  { 'folke/which-key.nvim', enabled = false },
  {
    '/local-config',
    dev = true,
    event = 'VeryLazy',
    config = function() pcall(require, 'local-config') end,
  },
  { 'JoosepAlviste/nvim-ts-context-commentstring' },
  {
    'numToStr/Comment.nvim',
    event = 'VeryLazy',
    config = function()
      require('Comment').setup({
        pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
      })
    end,
  },
  {
    'windwp/nvim-autopairs',
    event = 'VeryLazy',
    config = function() require('nvim-autopairs').setup({}) end,
  },
  {
    'eandrju/cellular-automaton.nvim',
    cmd = 'Oops',
    config = function()
      vim.api.nvim_create_user_command(
        'Oops',
        function() require('cellular-automaton').start_animation('make_it_rain') end,
        {}
      )
    end,
  },
  {
    'rmagatti/auto-session',
    lazy = false,

    ---@module "auto-session"
    ---@type AutoSession.Config
    opts = {
      suppressed_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
    },
  },
  {
    'tpope/vim-sleuth',
    event = 'BufReadPre',
  },
  {
    'tpope/vim-repeat',
    event = 'VeryLazy',
  },
  {
    'chrisgrieser/nvim-various-textobjs',
    event = 'VeryLazy',
    opts = {
      keymaps = {
        useDefaults = true,
        disabledDefaults = { 'gc' },
      },
    },
  },
  {
    'kevinhwang91/nvim-bqf',
    event = 'VeryLazy',
    config = {
      auto_preview = {
        default = false,
      },
    },
  },
  {
    'abecodes/tabout.nvim',
    event = 'VeryLazy',
  },
  {
    'rcarriga/nvim-notify',
    enabled = true,
    opts = {
      timeout = 2000,
      stages = 'static',
      max_height = function() return math.floor(vim.o.lines * 0.75) end,
      max_width = function() return math.floor(vim.o.columns * 0.75) end,
      top_down = false,
    },
    init = function() vim.notify = require('notify') end,
  },
  {
    'stevearc/dressing.nvim',
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require('lazy').load({ plugins = { 'dressing.nvim' } })
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require('lazy').load({ plugins = { 'dressing.nvim' } })
        return vim.ui.input(...)
      end
    end,
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    ---@module "ibl"
    ---@type ibl.config
    opts = {
      scope = { enabled = false },
      indent = {
        char = '▏',
        tab_char = '▏',
      },
    },
  },
}
