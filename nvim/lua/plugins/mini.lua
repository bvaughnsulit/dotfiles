return {
  'echasnovski/mini.nvim',
  version = false,
  lazy = false,
  priority = 1000,
  config = function()
    -- vim.cmd 'colorscheme minischeme'
    require('mini.cursorword').setup({})
    require('mini.surround').setup({})
    require('mini.ai').setup({})
    require('mini.move').setup({})
    local map = require('mini.map')
    map.setup({
      integrations = {
        map.gen_integration.builtin_search(),
        map.gen_integration.gitsigns({
          add = 'GitSignsChange',
          change = 'GitSignsChange',
          delete = 'GitSignsChange',
        }),
        map.gen_integration.diagnostic(),
      },
      symbols = {
        encode = map.gen_encode_symbols.block('2x1'),
        scroll_line = '',
        scroll_view = '┃',
      },
      window = {
        show_integration_count = false,
        width = 2,
        winblend = 0,
      },
    })
  end,
}
