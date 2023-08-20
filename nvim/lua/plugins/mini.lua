return {
  'echasnovski/mini.nvim',
  version = false,
  lazy = false,
  priority = 1000,
  config = function()
    require('mini.cursorword').setup({})
    require('mini.surround').setup({
      mappings = {
        add = 'gza', -- Add surrounding in Normal and Visual modes
        delete = 'gzd', -- Delete surrounding
        find = 'gzf', -- Find surrounding (to the right)
        find_left = 'gzF', -- Find surrounding (to the left)
        highlight = 'gzh', -- Highlight surrounding
        replace = 'gzr', -- Replace surrounding
        update_n_lines = 'gzn', -- Update `n_lines`
        suffix_last = 'l', -- Suffix to search with "prev" method
        suffix_next = 'n', -- Suffix to search with "next" method
      },
    })
    require('mini.ai').setup({})
    require('mini.move').setup({})
    require('mini.operators').setup({
      replace = { prefix = 'gp' },
    })
    require('mini.indentscope').setup({
      draw = {
        animation = require('mini.indentscope').gen_animation.none(),
      },
      options = {
        indent_at_cursor = true,
        try_as_border = true,
      },
      symbol = '▏',
    })
  end,
}
