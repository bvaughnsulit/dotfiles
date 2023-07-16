return {
  {
    '/local-config',
    dev = true,
    event = 'VeryLazy',
    config = function() pcall(require, 'local-config') end,
  },
  { 'tpope/vim-fugitive', cmd = 'G' },
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
    'chrisgrieser/nvim-various-textobjs',
    event = 'VeryLazy',
    opts = { useDefaultKeymaps = true },
  },
  {
    'lewis6991/satellite.nvim',
    event = 'VeryLazy',
    dev = true,
    config = function()
      require('satellite').setup({
        current_only = false,
        winblend = 0,
        zindex = 40,
        excluded_filetypes = {},
        width = 2,
        handlers = {
          search = {
            enable = true,
          },
          diagnostic = {
            enable = false,
            signs = { '-', '=', '≡' },
            min_severity = vim.diagnostic.severity.HINT,
          },
          gitsigns = {
            enable = true,
            signs = {
              add = '│',
              change = '│',
              delete = '-',
            },
          },
          marks = {
            enable = true,
            show_builtins = false, -- shows the builtin marks like [ ] < >
          },
        },
      })
      vim.cmd([[hi! link ScrollView PmenuThumb]])
      -- vim.cmd([[hi! link SearchCurrent SearchSV]])
    end,
  },
  {
    'ggandor/leap.nvim',
    enabled = false,
    config = function()
      require('leap').add_default_mappings()
      -- vim.keymap.set({ 'n', 'x', 'o' }, 's', function()
      --   local current_window = vim.fn.win_getid()
      --   require('leap').leap({ target_windows = { current_window } })
      -- end)
    end,
    event = 'BufReadPost',
  },
  {
    'ggandor/flit.nvim',
    enabled = false,
    event = 'BufReadPost',
    config = function() require('flit').setup({ labeled_modes = 'nx' }) end,
  },
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    enabled = true,
    opts = {
      -- label = {
      --   after = false,
      --   before = true,
      --   style = 'eol',
      -- },
      modes = {
        search = {
          enabled = false,
        },
      },
    },
    keys = {
      {
        's',
        mode = { 'n', 'x', 'o' },
        function()
          -- default options: exact mode, multi window, all directions, with a backdrop
          require('flash').jump()
        end,
        desc = 'Flash',
      },
      {
        'S',
        mode = { 'n', 'o', 'x' },
        function() require('flash').treesitter() end,
        desc = 'Flash Treesitter',
      },
      {
        'r',
        mode = 'o',
        function() require('flash').remote() end,
        desc = 'Remote Flash',
      },
      {
        'R',
        mode = { 'o', 'x' },
        function() require('flash').treesitter_search() end,
        desc = 'Flash Treesitter Search',
      },
      {
        '<c-s>',
        mode = { 'c' },
        function() require('flash').toggle() end,
        desc = 'Toggle Flash Search',
      },
    },
  },
  {
    'LazyVim/LazyVim',
  },
}
