require("setup.settings")
require("setup.plugins")
require("setup.keymaps")
require('setup.functions')
require('setup.tmux')

require('setup.config.bufferline')
require('setup.config.cinnamon')
require('setup.config.gitsigns')
require('setup.config.indent-blankline')
require('setup.config.lsp')
require('setup.config.lualine')
require('setup.config.mini')
require('setup.config.navigator')
require('setup.config.nvim-tree')
require('setup.config.nvim-treesitter')
require('setup.config.telescope')
require('setup.config.trouble')

require('setup.theme')

vim.cmd('colorscheme minischeme')
