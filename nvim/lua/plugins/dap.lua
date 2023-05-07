local utils = require('config.utils')

return {
  {
    'mfussenegger/nvim-dap',
    event = 'VeryLazy',
    dependencies = {
      { 'rcarriga/nvim-dap-ui' },
      {
        'jay-babu/mason-nvim-dap.nvim',
        dependencies = 'mason.nvim',
        cmd = { 'DapInstall', 'DapUninstall' },
        config = function()
          require('mason-nvim-dap').setup({
            automatic_setup = true,
            ensure_installed = {
              'js',
              -- 'python',
            },
          })
        end,
      },
      'mxsdev/nvim-dap-vscode-js',
      'mfussenegger/nvim-dap-python',
    },
    config = function()
      local dap = require('dap')
      local dapui = require('dapui')
      dapui.setup()

      utils.create_cmd_and_map(
        'DapUIToggle',
        nil,
        function() require('dapui').toggle({}) end,
        'Toggle Dap UI'
      )

      dap.listeners.after.event_initialized['dapui_config'] = function() dapui.open({}) end
      dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close({}) end
      dap.listeners.before.event_exited['dapui_config'] = function() dapui.close({}) end

      require('dap-python').setup()
      require('dap-vscode-js').setup({
        debugger_path = vim.fn.stdpath('data') .. '/mason/packages/js-debug',
        adapters = {
          'pwa-node',
          'pwa-chrome',
          'pwa-msedge',
          'node-terminal',
          'pwa-extensionHost',
        },
      })

      for _, language in ipairs({ 'typescript', 'javascript' }) do
        require('dap').configurations[language] = {
          {
            type = 'pwa-node',
            request = 'launch',
            name = 'Launch file',
            program = '${file}',
            cwd = '${workspaceFolder}',
          },
          {
            type = 'pwa-node',
            request = 'attach',
            name = 'Attach',
            processId = require('dap.utils').pick_process,
            cwd = '${workspaceFolder}',
          },
        }
      end
    end,
  },
}
