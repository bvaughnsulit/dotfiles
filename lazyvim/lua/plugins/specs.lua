return {
  { 'akinsho/bufferline.nvim', enabled = false },
  { 'windwp/nvim-ts-autotag', enabled = false },
  {
    '/local-config',
    dev = true,
    event = 'VeryLazy',
    config = function() pcall(require, 'local-config') end,
  },
  { 'tpope/vim-fugitive' },
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
    opts = {
      useDefaultKeymaps = true,
      disabledKeymaps = { 'gc' },
    },
  },
  {
    'lewis6991/satellite.nvim',
    enabled = false,
    event = 'VeryLazy',
    dev = false,
    config = function()
      require('satellite').setup({
        current_only = false,
        winblend = 0,
        zindex = 40,
        excluded_filetypes = {},
        width = 2,
        handlers = {
          cursor = {
            enable = false,
          },
          search = {
            enable = true,
            symbols = { '━', '🬋' },
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
    'folke/flash.nvim',
    event = 'VeryLazy',
    enabled = true,
    opts = {
      label = {
        uppercase = false,
      },
      modes = {
        search = {
          enabled = false,
        },
        char = {
          config = function(opts)
            opts.jump_labels = vim.v.count == 0 and not vim.fn.mode(true):find('o')
          end,
        },
      },
      prompt = { enabled = false },
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
    'chentoast/marks.nvim',
    event = 'VeryLazy',
    config = true,
    keys = {
      {
        '<leader>mm',
        mode = { 'n' },
        function()
          require('marks').mark_state:all_to_list()
          vim.cmd('lopen')
        end,
        { desc = 'Toggle mark visual' },
      },
    },
  },
  {
    'kevinhwang91/nvim-bqf',
    event = 'VeryLazy',
  },
  {
    'abecodes/tabout.nvim',
    event = 'VeryLazy',
  },
  {
    'folke/which-key.nvim',
    opts = {
      defaults = {
        ['<leader>w'] = 'which_key_ignore',
      },
    },
  },
}
