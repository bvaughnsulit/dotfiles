return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons', lazy = true },
  event = 'VeryLazy',
  config = function()
    require('lualine').setup {
      options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {
          'NvimTree',
        },
        always_divide_middle = true,
        globalstatus = true,
        refresh = {
          statusline = 1000,
          winbar = 1000,
        },
      },
      sections = {
        lualine_a = { 'mode' },
        -- TODO: can i truncate branch?
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = {
          {
            'filename',
            path = 1,
            symbols = { modified = '*' },
          },
        },
        lualine_x = { 'searchcount', 'location' },
        -- TODO: remove progress
        lualine_y = { 'progress' },
        lualine_z = { 'filetype' },
      },
      winbar = {
        lualine_a = {
          {
            'filename',
            symbols = { modified = '*' },
          },
        },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
      inactive_winbar = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {
          {
            'filename',
            symbols = { modified = '*' },
          },
        },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
      extensions = {},
    }
  end,
}
