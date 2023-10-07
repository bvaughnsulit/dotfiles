return {
  'lukas-reineke/indent-blankline.nvim',
  event = 'BufReadPost',
  main = 'ibl',
  dependencies = 'nvim-treesitter/nvim-treesitter',
  config = function()
    require('ibl').setup({
      indent = {
        char = '▏',
      },
      scope = {
        enabled = false,
      },
    })
  end,
}
