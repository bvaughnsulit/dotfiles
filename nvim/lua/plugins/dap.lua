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
            ensure_installed = {},
          })
        end,
      },
      {
        'theHamsta/nvim-dap-virtual-text',
        config = function() require('nvim-dap-virtual-text').setup() end,
      },
      'mxsdev/nvim-dap-vscode-js',
      'mfussenegger/nvim-dap-python',
    },
    config = function()
      local dap = require('dap')
      local dapui = require('dapui')
      dapui.setup()
      require('dap.ext.vscode').load_launchjs()

      -- dap.listeners.after.event_initialized['dapui_config'] = function() dapui.open({}) end
      -- dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close({}) end
      -- dap.listeners.before.event_exited['dapui_config'] = function() dapui.close({}) end

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

      utils.create_cmd_and_map(
        'DapUIToggle',
        '<leader>dd',
        function() require('dapui').toggle({}) end,
        'Toggle Dap UI'
      )
      -- utils.create_cmd_and_map(
      --   'BreakpointCondition',
      --   '<leader>dB',
      --   function()
      --     require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))
      --   end,
      --   'Breakpoint Condition',
      -- )
      utils.create_cmd_and_map(
        'DapToggleBreakpoint',
        '<leader>db',
        function() require('dap').toggle_breakpoint() end,
        'Toggle Breakpoint'
      )
      utils.create_cmd_and_map(
        'DapContinue',
        '<leader>dc',
        function() require('dap').continue() end,
        'Continue'
      )
      utils.create_cmd_and_map(
        'DapStepInto',
        '<leader>di',
        function() require('dap').step_into() end,
        'Step Into'
      )
      utils.create_cmd_and_map(
        'DapDown',
        '<leader>dj',
        function() require('dap').down() end,
        'DAP Down'
      )
      utils.create_cmd_and_map('DapUp', '<leader>dk', function() require('dap').up() end, 'DAP Up')
      utils.create_cmd_and_map(
        'DapRunLast',
        '<leader>dl',
        function() require('dap').run_last() end,
        'Run Last'
      )
      utils.create_cmd_and_map(
        'DapStepOut',
        '<leader>do',
        function() require('dap').step_out() end,
        'Step Out'
      )
      utils.create_cmd_and_map(
        'DapStepOver',
        '<leader>dO',
        function() require('dap').step_over() end,
        'Step Over'
      )
      utils.create_cmd_and_map(
        'DapPause',
        '<leader>dp',
        function() require('dap').pause() end,
        'Pause'
      )
      utils.create_cmd_and_map(
        'DapToggleREPL',
        '<leader>dr',
        function() require('dap').repl.toggle() end,
        'Toggle REPL'
      )
      utils.create_cmd_and_map(
        'DapSession',
        '<leader>ds',
        function() require('dap').session() end,
        'Session'
      )
      utils.create_cmd_and_map(
        'DapTerminate',
        '<leader>dt',
        function() require('dap').terminate() end,
        'Terminate'
      )
      utils.create_cmd_and_map(
        'DapWidgets',
        '<leader>dw',
        function() require('dap.ui.widgets').hover() end,
        'Widgets'
      )
      utils.create_cmd_and_map(
        'DapRuntoCursor',
        '<leader>dC',
        function() require('dap').run_to_cursor() end,
        'Run to Cursor'
      )
      utils.create_cmd_and_map(
        'DapGotolinenoexecute',
        '<leader>dg',
        function() require('dap').goto_() end,
        'Go to line (no execute)'
      )
    end,
  },
}
