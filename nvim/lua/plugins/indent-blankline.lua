return {
  'lukas-reineke/indent-blankline.nvim',
  event = 'BufReadPost',
  config = function()
    require('indent_blankline').setup {
      indent_blankline_char = '▏',
      indent_blankline_context_char = '▏',
      space_char_blankline = ' ',
      show_current_context = true,
      show_current_context_start = true,
      use_treesitter = true,
      use_treesitter_scope = true,
      show_trailing_blankline_indent = false,
      show_first_indent_level = true,
    }

    -- unclear why including these options in the setup above doesn't work
    vim.cmd "let g:indent_blankline_char='▏'"
    vim.cmd "let g:indent_blankline_context_char='▏'"
  end,
}
