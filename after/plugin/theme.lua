require('material').setup{
	custom_highlights = {
		MiniCursorword = { link = "Search" },
		MiniCursorwordCurrent = { link = "Search" },
	}
}

-- browse themes
vim.api.nvim_create_user_command(
  'ThemeBrowse',
  function ()
    require('telescope.builtin').colorscheme(
      { enable_preview = true }
    )
  end, {}
)

vim.api.nvim_create_user_command(
  'ThemeGruvboxLight',
  function ()
    vim.g.gruvbox_material_background = 'medium'
    vim.opt.background=light
    vim.cmd('colorscheme gruvbox-material')
  end, {}
)

vim.api.nvim_create_user_command(
  'ThemeMaterialDeepOcean',
  function ()
    vim.g.material_style = "deep ocean"
    vim.cmd('colorscheme material')
  end, {}
)

vim.api.nvim_create_user_command(
  'ThemeMonokai',
  function ()
    vim.g.monokaipro_filter = "classic"
    vim.cmd('colorscheme monokaipro')
  end, {}
)
