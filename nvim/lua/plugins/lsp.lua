local telescope = require('telescope.builtin')
local telescope_dropdown = require('telescope.themes').get_dropdown

return {
  {
    'neovim/nvim-lspconfig',
    init = function()
      local keys = require('lvim_config.plugins.lsp.keymaps').get()
      keys[#keys + 1] = {
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
      }
      keys[#keys + 1] = {
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
      }
      keys[#keys + 1] = {
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
      }
    end,
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
          require('lvim_config.util').lsp.on_attach(function(client)
            if client.name == 'eslint' then
              client.server_capabilities.documentFormattingProvider = true
            elseif client.name == 'ts_ls' then
              client.server_capabilities.documentFormattingProvider = false
            end
          end)
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
