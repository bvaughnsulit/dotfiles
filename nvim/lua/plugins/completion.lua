return {
  {
    'L3MON4D3/LuaSnip',
    dependencies = {
      'rafamadriz/friendly-snippets',
      config = function()
        local luasnip = require('luasnip')
        require('luasnip.loaders.from_vscode').lazy_load()
        luasnip.filetype_extend('typescript', { 'javascript', 'tsdoc' })
        luasnip.filetype_extend('typescriptreact', { 'javascript', 'tsdoc' })

        vim.keymap.set('i', '<S-Tab>', function()
          if luasnip.jumpable(-1) then luasnip.jump(-1) end
        end)
      end,
    },
  },
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    config = function()
      require('copilot').setup({
        panel = { enabled = false },
        enabled = true,
        suggestion = {
          auto_trigger = true,
          debounce = 10,
          keymap = {
            accept = false,
            accept_word = false,
            accept_line = false,
            next = '<M-]>',
            prev = '<M-[>',
            dismiss = '<C-]>',
          },
        },
        filetypes = {},
      })
      vim.keymap.set('i', '<Tab>', function()
        local luasnip = require('luasnip')
        if require('copilot.suggestion').is_visible() then
          require('copilot.suggestion').accept()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        else
          vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes('<Tab>', true, false, true),
            'n',
            false
          )
        end
      end)
    end,
  },
  {
    'saghen/blink.cmp',
    dependencies = 'rafamadriz/friendly-snippets',
    enabled = true,
    version = 'v0.10.0',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = 'enter',
        ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
      },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono',
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
      completion = {
        menu = { border = 'single' },
        list = {
          selection = {
            preselect = false,
            auto_insert = true,
          },
        },
        documentation = {
          window = { border = 'single' },
          auto_show = true,
          auto_show_delay_ms = 300,
        },
      },
      signature = {
        window = { border = 'single' },
        enabled = true,
      },
    },
    opts_extend = { 'sources.default' },
  },
}
