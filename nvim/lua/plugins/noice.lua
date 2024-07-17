return {
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    -- dev = true,
    opts = {
      cmdline = {
        enabled = true,
        view = 'cmdline',
      },
      messages = {
        enabled = true,
        view = 'notify',
      },
      lsp = {
        progress = { enabled = false },
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true,
        },
        signature = {
          enabled = true,
          auto_open = {
            enabled = true,
          },
        },
      },
      presets = {
        long_message_to_split = true,
        lsp_doc_border = true,
        bottom_search = true,
      },
      views = {
        mini = {
          position = {
            col = 0,
            row = -2,
          },
          size = {
            height = 'auto',
            width = '50%',
          },
        },
        cmdline = {
          win_options = { winblend = 0 },
          position = {
            row = -1,
          },
        },
        virtualtext = {
          hl_group = 'CurSearch',
        },
        popup = {
          enter = false,
        },
        notify = {
          replace = true,
        },
      },
      routes = {
        -- {
        --   view = 'popup',
        --   filter = {},
        -- },
      },
    },
    dependencies = {
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify',
    },
    keys = {
      { '<c-f>', false },
      { '<c-b>', false },
    },
  },
}
