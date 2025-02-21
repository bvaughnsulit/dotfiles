return {
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
}
