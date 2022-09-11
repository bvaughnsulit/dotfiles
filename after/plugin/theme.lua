-- set custom word highlights for material
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

local themes = {}

themes.gruvboxLight = function ()
  vim.g.gruvbox_material_background = 'medium'
  vim.opt.background=light
  vim.cmd('colorscheme gruvbox-material')
end
vim.api.nvim_create_user_command('GruvboxLight', themes.gruvboxLight, {})

themes.materialDeepOcean = function ()
  vim.g.material_style = "deep ocean"
  vim.cmd('colorscheme material')
end
vim.api.nvim_create_user_command( 'MateriaDeepOcean', themes.materialDeepOcean, {})


themes.monokai = function ()
  vim.g.monokaipro_filter = "classic"
  vim.cmd('colorscheme monokaipro')
end
vim.api.nvim_create_user_command('Monokai', themes.monokai, {})


themes.catppuccin = function ()
  vim.g.catppuccin_flavour = "mocha"
  vim.cmd('colorscheme catppuccin')
end
vim.api.nvim_create_user_command('CatppuccinMocha', themes.catppuccin, {})


themes.tokyonight = function ()
  vim.cmd('colorscheme tokyonight')
end
vim.api.nvim_create_user_command('TokyoNight', themes.tokyonight, {})

-- set random theme
local setRandomTheme = function()
  local keys = {}
  for key, _ in pairs(themes) do table.insert(keys, key) end
  local randomTheme = keys[math.random(1, #keys)]
  themes[randomTheme]()
  print(randomTheme)
end

setRandomTheme()

vim.api.nvim_create_user_command('RandomTheme', setRandomTheme, {})
