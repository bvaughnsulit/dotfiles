return {
  {
    'rcarriga/nvim-notify',
    enabled = true,
    lazy = false,
    init = function()
      local notify = require('notify')
      notify.setup({
        timeout = 2000,
        stages = 'slide',
        max_height = function() return math.floor(vim.o.lines * 0.75) end,
        max_width = function() return math.floor(vim.o.columns * 0.75) end,
        top_down = false,
      })
      vim.notify = notify
    end,
  },
  {
    'stevearc/dressing.nvim',
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require('lazy').load({ plugins = { 'dressing.nvim' } })
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require('lazy').load({ plugins = { 'dressing.nvim' } })
        return vim.ui.input(...)
      end
    end,
  },
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
  {
    'lukas-reineke/indent-blankline.nvim',
    version = '3.4', -- remove once bug is fixed
    opts = {
      indent = {
        char = '▏',
        tab_char = '▏',
      },
    },
  },
  {
    'echasnovski/mini.indentscope',
    opts = {
      draw = {
        animation = require('mini.indentscope').gen_animation.none(),
      },
      options = {
        indent_at_cursor = true,
        try_as_border = true,
      },
      symbol = '▏',
    },
  },
}
