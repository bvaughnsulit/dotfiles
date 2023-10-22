local utils = require('config.utils')

return {
  {
    'neovim/nvim-lspconfig',
    event = 'BufReadPre',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'hrsh7th/cmp-nvim-lsp',
      'folke/neodev.nvim',
      {
        'SmiteshP/nvim-navbuddy',
        enabled = false,
        dependencies = {
          {
            'SmiteshP/nvim-navic',
            opts = { highlight = true },
          },
          'MunifTanjim/nui.nvim',
        },
        config = function()
          local navbuddy = require('nvim-navbuddy')
          local actions = require('nvim-navbuddy.actions')
          navbuddy.setup({
            window = {
              border = 'rounded',
              sections = {
                right = {
                  preview = 'always',
                },
              },
            },
            lsp = {
              auto_attach = true,
            },
          })
        end,
      },
    },
    config = function()
      local t = require('telescope.builtin')
      local t_dropdown = require('telescope.themes').get_dropdown

      local telescope_def = function()
        t.lsp_definitions(t_dropdown({
          layout_config = {
            anchor = 'N',
            width = 0.9,
          },
        }))
      end

      local telescope_ref = function()
        t.lsp_references(t_dropdown({
          layout_config = {
            anchor = 'N',
            width = 0.9,
          },
        }))
      end

      -- things that will be set up when lsp attaches to a buffer
      local on_attach = function(client, bufnr)
        -- if client.server_capabilities.documentSymbolProvider then
        --   require('nvim-navic').attach(client, bufnr)
        -- end

        vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr })
        vim.keymap.set('n', 'gd', telescope_def, { buffer = bufnr })
        vim.keymap.set('n', 'gr', telescope_ref, { buffer = bufnr })
        vim.keymap.set('n', 'gK', vim.lsp.buf.signature_help, { buffer = bufnr })
        vim.keymap.set('i', '<c-k>', vim.lsp.buf.signature_help, { buffer = bufnr })
        vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, { buffer = bufnr })
        -- vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { buffer = bufnr })
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { buffer = bufnr })
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { buffer = bufnr })

        --diagnostics
        vim.keymap.set('n', 'gK', vim.diagnostic.open_float, {})
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, {})
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, {})

        utils.create_cmd_and_map(
          'InlineDiagnosticsToggle',
          '<leader>di',
          function()
            vim.diagnostic.config({
              virtual_text = not vim.diagnostic.config().virtual_text,
            })
          end,
          'toggle inline diagnostics'
        )

        -- set up EslintFixAll on save and mapping
        if client.name == 'eslint' then
          local augroup = vim.api.nvim_create_augroup('EslintFix', {})
          vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
          vim.api.nvim_create_autocmd('BufWritePre', {
            group = augroup,
            buffer = bufnr,
            command = 'EslintFixAll',
          })
          vim.keymap.set('n', '<leader>bf', '<cmd>EslintFixAll<cr>', { buffer = bufnr })
        end
      end

      -- lsp server setup
      require('neodev').setup({})
      local lspconfig = require('lspconfig')

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

      local servers = {
        'pyright',
        'tsserver',
        'eslint',
        'lua_ls',
        'volar',
        'cssls',
        -- 'dockerls',
        'html',
        -- 'emmet_ls',
        'jsonls',
        -- 'tailwindcss',
        'vimls',
        'denols',
      }

      require('mason-lspconfig').setup({ ensure_installed = servers })

      for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup({
          on_attach = on_attach,
          capabilities = capabilities,
          single_file_support = true,
        })
      end

      -- custom deno config
      lspconfig.denols.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        single_file_support = false,
        root_dir = lspconfig.util.root_pattern('deno.json', 'deno.jsonc'),
      })

      -- custom tsserver config
      lspconfig.tsserver.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        single_file_support = false,
        root_dir = lspconfig.util.root_pattern('package.json', 'tsconfig.json'),
      })

      lspconfig.pyright.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        single_file_support = true,
        settings = {
          python = {
            analysis = {
              typeCheckingMode = 'off',
            },
          },
        },
      })

      -- custom lua configs
      lspconfig.lua_ls.setup({
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
      })

      -- custom vue (volar) configs
      lspconfig.volar.setup({
        init_options = {
          typescript = {
            -- putting this as an absolute path feels unwise. need to find a better way.
            serverPath = '/Users/vaughn/.nvm/versions/node/v16.16.0/lib/node_modules/typescript/lib/tsserverlibrary.js',
          },
        },
      })

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
      vim.diagnostic.config({
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
      })
    end,
  },
  {
    'ray-x/lsp_signature.nvim',
    event = 'BufReadPre',
    enabled = false,
    config = function()
      require('lsp_signature').setup({
        hint_enable = false,
        fix_pos = true,
      })
    end,
  },
  {
    'williamboman/mason.nvim',
    lazy = true,
    cmd = 'Mason',
    config = function() require('mason').setup() end,
  },
  {
    'jose-elias-alvarez/null-ls.nvim',
    event = 'BufReadPre',
    config = function()
      local null_ls = require('null-ls')

      -- call lsp format method using only null-ls
      local lsp_formatting = function(buf)
        vim.lsp.buf.format({
          filter = function(formatting_client) return formatting_client.name == 'null-ls' end,
          bufnr = buf,
        })
      end

      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.stylua,
          null_ls.builtins.diagnostics.pylint,
        },
        on_attach = function(client, bufnr)
          if client.supports_method('textDocument/formatting') then
            local augroup = vim.api.nvim_create_augroup('LspFormatting', {})
            vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
            vim.api.nvim_create_autocmd('BufWritePre', {
              group = augroup,
              buffer = bufnr,
              callback = function() lsp_formatting(bufnr) end,
            })
            vim.keymap.set('n', '<leader>bf', lsp_formatting, { buffer = bufnr })
          end
        end,
      })
    end,
  },
}
