local utils = require('config.utils')
return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons', lazy = true },
  event = 'VeryLazy',
  config = function()
    require('lualine').setup({
      options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = { left = '', right = '' }, --
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
          statusline = {},
          winbar = { 'dap-repl', 'neo-tree' },
        },
        ignore_focus = {
          'neo-tree',
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
        lualine_b = {
          {
            'branch',
            fmt = function(str, _)
              local maxLen = 12
              if string.len(str) > maxLen then
                return string.sub(str, 1, maxLen) .. '...'
              else
                return str
              end
            end,
          },
        },
        lualine_c = {
          {
            'filename',
            path = 1,
            symbols = { modified = '*' },
          },
        },
        lualine_x = {},
        lualine_y = { 'location' },
        lualine_z = { 'filetype' },
      },
      winbar = {
        lualine_a = {
          {
            'filename',
            symbols = { modified = '*' },
          },
        },
        lualine_b = {
          'diagnostics',
        },
        -- lualine_c = { 'navic', color_correction = nil, navic_opts = nil },
        -- lualine_c = { 'aerial' },
        lualine_x = {},
        lualine_y = {},
        lualine_z = { function() return utils.get_path_tail(vim.loop.cwd()) end },
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
    })
  end,
}
