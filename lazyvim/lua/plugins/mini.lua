return {
  'echasnovski/mini.nvim',
  version = false,
  config = function()
    require('mini.cursorword').setup({})
    require('mini.surround').setup({
      mappings = {
        add = 'gsa', -- Add surrounding in Normal and Visual modes
        delete = 'gsd', -- Delete surrounding
        find = 'gsf', -- Find surrounding (to the right)
        find_left = 'gsF', -- Find surrounding (to the left)
        highlight = 'gsh', -- Highlight surrounding
        replace = 'gsr', -- Replace surrounding
        update_n_lines = 'gsn', -- Update `n_lines`
        suffix_last = 'l', -- Suffix to search with "prev" method
        suffix_next = 'n', -- Suffix to search with "next" method
      },
    })
    require('mini.ai').setup({})
    require('mini.move').setup({})
    require('mini.operators').setup({
      replace = { prefix = 'gp' },
    })
  end,
  keys = {
    { '<A-j>', nil, mode = { 'n', 'v' } },
    { '<A-k>', nil, mode = { 'n', 'v' } },
  },
}
