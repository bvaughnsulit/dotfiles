local actions = require("telescope.actions")
require('telescope').setup{
  defaults = {
    layout_strategy = 'vertical',
    layout_config = {
      mirror = true,
      prompt_position = "top",
      width = 0.8,
      height = 0.95,
      preview_cutoff = 0,
    },
    pickers = {
      buffers = {
        ignore_current_buffer = true,
        sort_mru = true,
      },
    },
    file_ignore_patterns = { "package-lock.json" },
    mappings = {
      i = {
        ["<esc>"] = actions.close,
        ["<C-u>"] = false,
      },
    },
  }
}
require('telescope').load_extension('fzf')
