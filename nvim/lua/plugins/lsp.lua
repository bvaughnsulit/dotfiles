return {
  {
    'neovim/nvim-lspconfig',
    event = 'BufReadPre',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'hrsh7th/cmp-nvim-lsp',
      'folke/neodev.nvim',
    },
    config = function()
      -- things that will be set up when lsp attaches to a buffer
      local on_attach = function(client, bufnr)
        -- call lsp format method using only null-ls
        local lsp_formatting = function(buf)
          vim.lsp.buf.format {
            filter = function(formatting_client)
              return formatting_client.name == 'null-ls'
            end,
            bufnr = buf,
          }
        end

        vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr })
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = bufnr })
        vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, { buffer = bufnr })
        vim.keymap.set('n', 'gK', vim.lsp.buf.signature_help, { buffer = bufnr })
        vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, { buffer = bufnr })
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { buffer = bufnr })
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { buffer = bufnr })
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { buffer = bufnr })
        vim.keymap.set('n', '<leader>bf', lsp_formatting, { buffer = bufnr })

        --diagnostics
        vim.keymap.set('n', '<leader>dd', vim.diagnostic.open_float, {})
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, {})
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, {})

        -- toggle inline diagnostics
        local toggle_inline_diagnostics = function()
          vim.diagnostic.config {
            virtual_text = not vim.diagnostic.config().virtual_text,
          }
        end
        vim.keymap.set(
          'n',
          '<leader>di',
          toggle_inline_diagnostics,
          { desc = 'toggle inline diagnostics' }
        )
        vim.api.nvim_create_user_command('InlineDiagnosticsToggle', toggle_inline_diagnostics, {})

        -- format on save
        if client.supports_method 'textDocument/formatting' then
          local augroup = vim.api.nvim_create_augroup('LspFormatting', {})
          vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
          vim.api.nvim_create_autocmd('BufWritePre', {
            group = augroup,
            buffer = bufnr,
            callback = function()
              lsp_formatting(bufnr)
            end,
          })
        end
      end

      -- lsp server setup
      require('neodev').setup {}
      local lspconfig = require 'lspconfig'

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

      local servers = {
        'pyright',
        'tsserver',
        'eslint',
        'sumneko_lua',
        'volar',
        'cssls',
        'dockerls',
        'html',
        'emmet_ls',
        'jsonls',
        -- 'tailwindcss',
        'vimls',
        'denols',
      }

      require('mason-lspconfig').setup { ensure_installed = servers }

      for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup {
          on_attach = on_attach,
          capabilities = capabilities,
          single_file_support = true,
        }
      end

      -- custom deno config
      lspconfig.denols.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        single_file_support = false,
        root_dir = lspconfig.util.root_pattern('deno.json', 'deno.jsonc'),
      }

      -- custom tsserver config
      lspconfig.tsserver.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        single_file_support = false,
        root_dir = lspconfig.util.root_pattern('package.json', 'tsconfig.json'),
      }

      -- custom lua configs
      lspconfig.sumneko_lua.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          Lua = {
            -- runtime = { version = 'LuaJIT' },
            diagnostics = { globals = { 'vim' } },
            workspace = {
              -- library = vim.api.nvim_get_runtime_file('', true),
              checkThirdParty = false,
            },
            completion = {
              callSnippet = 'Replace',
            },
            -- telemetry = { enable = false },
          },
        },
      }

      -- custom vue (volar) configs
      lspconfig.volar.setup {
        init_options = {
          typescript = {
            -- putting this as an absolute path feels unwise. need to find a better way.
            serverPath = '/Users/vaughn/.nvm/versions/node/v16.16.0/lib/node_modules/typescript/lib/tsserverlibrary.js',
          },
        },
      }

      -- diagnostics
      -- currently configured to only apply highlights to line numbers, and not display signs
      local signs = { Error = ' ', Warn = ' ', Hint = ' ', Info = ' ' }
      for type, _ in pairs(signs) do
        local hl = 'DiagnosticSign' .. type
        vim.fn.sign_define(hl, {
          numhl = hl,
          -- texthl = hl,
        })
      end

      -- configure display of diagnostics and floats
      vim.diagnostic.config {
        signs = true,
        virtual_text = false,
        severity_sort = true,
        float = {
          wrap = true,
          max_width = 60,
          source = true,
          border = 'rounded',
          style = 'minimal',
        },
      }
      vim.lsp.handlers['textDocument/hover'] =
        vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' })
      vim.lsp.handlers['textDocument/signatureHelp'] =
        vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'single' })
    end,
  },
  {
    'ray-x/lsp_signature.nvim',
    event = "BufReadPre",
    config = function()
      require('lsp_signature').setup {
        hint_prefix = ' ',
      }
    end,
  },
  {
    'williamboman/mason.nvim',
    lazy = true,
    cmd = 'Mason',
    config = function()
      require('mason').setup()
    end,
  },
  {
    'jose-elias-alvarez/null-ls.nvim',
    event = "BufReadPre",
    config = function()
      local null_ls = require 'null-ls'

      local sources = {
        null_ls.builtins.formatting.prettier,
        null_ls.builtins.formatting.stylua,
      }
      null_ls.setup { sources = sources }
    end,
  },
}