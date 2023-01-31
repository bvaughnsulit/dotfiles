return {
  'Wansmer/treesj',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  event = 'VeryLazy',
  config = function()
    require('treesj').setup {
      use_default_keymaps = false,
      check_syntax_error = true,
      max_join_length = 80,
      cursor_behavior = 'hold',
      notify = true,
    }

    vim.keymap.set('n', '<leader><cr>', '<cmd>TSJToggle<cr>', {})
  end,
}
