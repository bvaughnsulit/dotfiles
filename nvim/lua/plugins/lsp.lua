return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
    },
    config = function()
      local lspconfig = require 'lspconfig'
      local luasnip = require 'luasnip'
      require('luasnip.loaders.from_vscode').lazy_load()
      local cmp = require 'cmp'

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

      -- call lsp format method using only null-ls
      local lsp_formatting = function(bufnr)
        vim.lsp.buf.format {
          filter = function(client)
            return client.name == 'null-ls'
          end,
          bufnr = bufnr,
        }
      end

      local augroup = vim.api.nvim_create_augroup('LspFormatting', {})

      local on_attach = function(client, bufnr)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr })
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = bufnr })
        vim.keymap.set('n', 'gr', require('telescope.builtin').lsp_references, { buffer = bufnr })
        -- vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, { buffer = bufnr })
        vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, { buffer = bufnr })
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { buffer = bufnr })
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { buffer = bufnr })
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { buffer = bufnr })
        vim.keymap.set('n', '<leader>bf', lsp_formatting, { buffer = bufnr })

        -- format on save
        if client.supports_method 'textDocument/formatting' then
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
            runtime = { version = 'LuaJIT' },
            diagnostics = { globals = { 'vim' } },
            workspace = {
              library = vim.api.nvim_get_runtime_file('', true),
              checkThirdParty = false,
            },
            telemetry = { enable = false },
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

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = {
          keyword_length = 2,
        },
        mapping = cmp.mapping.preset.insert {
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          },
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        },
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        }, {
          { name = 'buffer' },
          { name = 'nvim_lua' },
        }),
        formatting = {
          format = function(entry, vim_item)
            vim_item.menu = ({
              buffer = '[Buffer]',
              nvim_lsp = '[LSP]',
              luasnip = '[LuaSnip]',
              nvim_lua = '[Lua]',
            })[entry.source.name]
            return vim_item
          end,
        },
        experimental = {},
      }

      -- Use cmdline & path source for ':'
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' },
        }, {
          { name = 'cmdline' },
        }),
      })

      -- Use buffer source for `/`
      cmp.setup.cmdline('/', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'buffer' },
        },
      })

      -- define diagnostic signs, and highlights. currently configured to only
      -- highline line numbers, and not display signs
      local signs = { Error = ' ', Warn = ' ', Hint = ' ', Info = ' ' }
      for type, icon in pairs(signs) do
        local hl = 'DiagnosticSign' .. type
        vim.fn.sign_define(hl, {
          numhl = hl,
          -- texthl = hl,
        })
      end

      -- configure display of diagnostics and diagnostic floats
      vim.diagnostic.config {
        signs = true,
        virtual_text = false,
        float = {
          wrap = true,
          max_width = 60,
          source = true,
          border = 'rounded',
          style = 'minimal',
        },
      }

      vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' })

      vim.lsp.handlers['textDocument/signatureHelp'] =
        vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'single' })

      vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, {})
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, {})
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next, {})
      vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, {})
      vim.keymap.set('n', '<leader>di', function()
        vim.diagnostic.config {
          virtual_text = not vim.diagnostic.config().virtual_text,
        }
      end, {})
    end,
  },
  'hrsh7th/nvim-cmp',
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-path',
  'hrsh7th/cmp-cmdline',
  'L3MON4D3/LuaSnip',
  'saadparwaiz1/cmp_luasnip',
  'rafamadriz/friendly-snippets',
  {
    'ray-x/lsp_signature.nvim',
    config = function()
      require('lsp_signature').setup {
        hint_prefix = ' ',
      }
    end,
  },
  'hrsh7th/cmp-nvim-lua',
  {
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup()
    end,
  },
  {
    'jose-elias-alvarez/null-ls.nvim',
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
