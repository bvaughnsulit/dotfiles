local telescope = require('telescope.builtin')
local telescope_dropdown = require('telescope.themes').get_dropdown

return {
  {
    'neovim/nvim-lspconfig',
    keys = {
      {
        'gd',
        function()
          telescope.lsp_definitions(telescope_dropdown({
            layout_config = {
              anchor = 'N',
              width = 0.9,
            },
          }))
        end,
        { nowait = true },
      },
      {
        'gr',
        function()
          telescope.lsp_references(telescope_dropdown({
            layout_config = {
              anchor = 'N',
              width = 0.9,
            },
          }))
        end,
        { nowait = true },
      },
      {
        'gt',
        function()
          telescope.lsp_type_definitions(telescope_dropdown({
            layout_config = {
              anchor = 'N',
              width = 0.9,
            },
          }))
        end,
        { nowait = true },
      },
      { 'K', function() return vim.lsp.buf.hover() end, desc = 'Hover' },
      {
        'gK',
        function() return vim.lsp.buf.signature_help() end,
        desc = 'Signature Help',
      },
      {
        '<c-k>',
        function() return vim.lsp.buf.signature_help() end,
        mode = 'i',
        desc = 'Signature Help',
        -- has = 'signatureHelp',
      },
      {
        '<leader>ca',
        vim.lsp.buf.code_action,
        desc = 'Code Action',
        mode = { 'n', 'v' },
        -- has = 'codeAction',
      },
      {
        '<leader>cR',
        function() Snacks.rename.rename_file() end,
        desc = 'Rename File',
        mode = { 'n' },
        -- has = { 'workspace/didRenameFiles', 'workspace/willRenameFiles' },
      },
      {
        '<leader>cr',
        vim.lsp.buf.rename,
        desc = 'Rename',
        -- has = 'rename',
      },
      {
        '<leader>cA',
        LazyVim.lsp.action.source,
        desc = 'Source Action',
        -- has = 'codeAction',
      },
    },
    opts = {
      inlay_hints = { enabled = false },
      diagnostics = {
        virtual_text = false,
        float = {
          wrap = true,
          max_width = 120,
          source = true,
          border = 'rounded',
          style = 'minimal',
        },
      },
      servers = {
        pyright = {
          root_dir = function(fname)
            local util = require('lspconfig.util')
            return util.root_pattern('.git')(fname)
          end,
          settings = {
            python = {
              analysis = {
                typeCheckingMode = 'off',
              },
            },
          },
        },
        eslint = {
          settings = {
            workingDirectory = { mode = 'location' },
          },
        },
        vtsls = {
          settings = {
            typescript = {
              format = {
                enable = false,
              },
            },
          },
        },
        ts_ls = {
          enabled = false,
        },
      },
      setup = {
        eslint = function()
          vim.api.nvim_create_autocmd('LspAttach', {
            callback = function(args)
              local client = vim.lsp.get_client_by_id(args.data.client_id)
              if client and client.name == 'eslint' then
                client.server_capabilities.documentFormattingProvider = true
              elseif client and client.name == 'ts_ls' then
                client.server_capabilities.documentFormattingProvider = false
              end
            end,
          })
        end,
      },
    },
  },
  {
    'mfussenegger/nvim-lint',
    opts = {
      linters_by_ft = {
        python = { 'pylint' },
      },
    },
  },
}
