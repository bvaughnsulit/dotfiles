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
    'folke/noice.nvim',
    event = 'VeryLazy',
    opts = {
      cmdline = {
        enabled = true,
        view = 'cmdline',
      },
      messages = {
        view = 'mini',
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
            col = '0%',
          },
        },
        cmdline = {
          win_options = { winblend = 0 },
        },
      },
    },
    dependencies = {
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify',
    },
  },
}
