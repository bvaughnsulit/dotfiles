local utils = require('config.utils')

local is_pinned = false

return {
  'nvim-neo-tree/neo-tree.nvim',
  enabled = true,
  branch = 'v3.x',
  event = 'VeryLazy',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
  },
  config = function()
    vim.g.neo_tree_remove_legacy_commands = 1
    local neotree = require('neo-tree')
    neotree.setup({
      sources = {
        'filesystem',
        'git_status',
        'document_symbols',
      },
      source_selector = {
        winbar = true,
        sources = {
          { source = 'filesystem' },
          { source = 'git_status' },
          { source = 'document_symbols' },
        },
      },
      default_component_configs = {
        container = {
          enable_character_fade = false,
          width = '100%',
          right_padding = 0,
        },
        indent = {
          indent_size = 1,
          padding = 1,
          -- indent guides
          with_markers = true,
          indent_marker = '│',
          last_indent_marker = '└',
          highlight = 'NeoTreeIndentMarker',
          -- expander config, needed for nesting files
          with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
          expander_collapsed = '',
          expander_expanded = '',
          expander_highlight = 'NeoTreeExpander',
        },
        icon = {
          folder_closed = '',
          folder_open = '',
          folder_empty = '',
          folder_empty_open = '',
          default = '*',
          highlight = 'NeoTreeFileIcon',
        },
        modified = {
          symbol = '*',
          highlight = 'NeoTreeModified',
        },
        name = {
          trailing_slash = false,
          use_git_status_colors = true,
          highlight = 'NeoTreeFileName',
        },
        git_status = {
          symbols = {
            -- Change type
            deleted = '', -- '',
            modified = '',
            renamed = '➜',
            -- Status type
            untracked = '﬒',
            ignored = '',
            unstaged = '󰝦',
            staged = '󰝥',
            conflict = '',
          },
          align = 'right',
        },
      },
      hide_root_node = true,
      enable_diagnostics = false,
      enable_git_status = true,
      event_handlers = {
        {
          event = 'file_opened',
          handler = function(_)
            if not is_pinned then require('neo-tree.sources.manager').close_all() end
          end,
        },
      },
      -- log_level = 'error', -- "trace", "debug", "info", "warn", "error", "fatal"
      -- log_to_file = true, -- true, false, "/path/to/file.log", use :NeoTreeLogs to show the file
      window = {
        width = '25%',
        position = 'left',
        mappings = {
          ['/'] = {},
          ['<space><space>'] = { 'toggle_preview' },
          ['<tab>'] = { 'toggle_node' },
          ['z'] = 'noop',
          ['s'] = 'noop',
          ['v'] = 'open_vsplit',
        },
      },
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          never_show = { '.DS_Store' },
        },
        follow_current_file = { enabled = true },
        hijack_netrw_behavior = 'open_default',
        window = {
          mappings = {
            ['f'] = { 'fuzzy_finder' },
          },
        },
      },
      git_status = {
        window = {
          mappings = {
            ['f'] = 'noop',
            ['gg'] = 'noop',
          },
        },
      },
    })
    vim.keymap.set('n', '<leader>ee', '<cmd>Neotree toggle<cr>', {})

    utils.create_cmd_and_map(
      'ToggleIsExplorerPinned',
      nil,
      function() is_pinned = not is_pinned end,
      'Toggle Neotree auto close'
    )

    local branch_name = utils.get_default_branch_name()

    utils.create_cmd_and_map(
      'GitDiffExplore',
      '<leader>eg',
      function() vim.cmd('Neotree toggle git_base=' .. branch_name .. ' git_status') end,
      'Explore Git Diff from Main'
    )

    utils.create_cmd_and_map(
      'ExploreDocumentSymbols',
      '<leader>es',
      function() vim.cmd('Neotree toggle document_symbols') end,
      'Explore Document Symbols'
    )

    utils.create_cmd_and_map(
      'Close Neo-tree',
      '<leader>eq',
      function() vim.cmd('Neotree close') end,
      'Close Neo-tree'
    )

    vim.api.nvim_create_autocmd('TermClose', {
      pattern = '*lazygit',
      callback = function() require('neo-tree.sources.git_status').refresh() end,
    })

    vim.api.nvim_create_autocmd('VimLeavePre', {
      pattern = '*',
      callback = function() vim.cmd('Neotree close') end,
    })
  end,
}
