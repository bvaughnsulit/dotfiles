return {
  'echasnovski/mini.nvim',
  version = false,
  lazy = false,
  priority = 1000,
  config = function()
    require('mini.cursorword').setup({})
    require('mini.surround').setup({})
    require('mini.ai').setup({})
    require('mini.move').setup({})
  end,
}
