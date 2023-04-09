return {
  { 'tpope/vim-fugitive', cmd = 'G' },
  'JoosepAlviste/nvim-ts-context-commentstring',
  {
    'numToStr/Comment.nvim',
    event = 'VeryLazy',
    config = function()
      require('Comment').setup({
        pre_hook = require(
          'ts_context_commentstring.integrations.comment_nvim'
        ).create_pre_hook(),
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
    config = function()
      require('auto-session').setup({
        log_level = 'error',
        auto_session_suppress_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
      })
    end,
  },
  {
    'dstein64/vim-startuptime',
    cmd = 'StartupTime',
    config = function() vim.g.startuptime_tries = 10 end,
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
    'ggandor/leap.nvim',
    event = 'BufReadPost',
    config = function()
      require('leap').add_default_mappings(true)
      -- vim.keymap.del({ 'x', 'o' }, 'x')
      -- vim.keymap.del({ 'x', 'o' }, 'X')
    end,
  },
  {
    'ggandor/flit.nvim',
    enabled = true,
    event = 'BufReadPost',
    config = function() require('flit').setup({ labeled_modes = 'nx' }) end,
  },
}
