return {
  'nvim-neo-tree/neo-tree.nvim',
  enabled = false,
  branch = 'v2.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
  },
  config = function()
    vim.g.neo_tree_remove_legacy_commands = 1
    require('neo-tree').setup {
      window = {
        mappings = {
          ['<tab>'] = { 'toggle_preview' },
        },
        filesystem = {
          hijack_netrw_behavior = 'open_default',
        },
      },
    }
  end,
}
