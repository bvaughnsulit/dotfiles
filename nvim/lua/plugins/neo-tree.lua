return {
  'nvim-neo-tree/neo-tree.nvim',
  enabled = true,
  branch = 'v2.x',
  cmd = 'Neotree',
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
      vim.keymap.set('n', '<leader>ee', '<cmd>Neotree toggle<cr>', {}),
    }
  end,
}
