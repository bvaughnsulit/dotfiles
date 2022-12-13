local actions = require 'telescope.actions'
require('telescope').setup {
  defaults = {
    layout_strategy = 'vertical',
    path_display = {
      -- shorten = {
      --   exclude = {1, -1}
      -- }
    },
    color_devicons = true,
    layout_config = {
      mirror = true,
      prompt_position = 'top',
      width = 0.8,
      height = 0.95,
      preview_cutoff = 0,
    },
    pickers = {
      find_files = { -- why doesn't this work??
        hidden = true,
      },
      buffers = {
        theme = 'dropdown',
        ignore_current_buffer = true,
        sort_mru = true,
      },
    },
    file_ignore_patterns = {
      'package%-lock%.json',
      '^.git/',
      '%.png$',
      '%.svg$',
      '%.gif$',
      '%.jpg$',
      '%.jpeg$',
    },
    mappings = {
      i = {
        ['<esc>'] = actions.close,
        -- ["<C-u>"] = false,
      },
    },
  },
}
require('telescope').load_extension 'fzf'
