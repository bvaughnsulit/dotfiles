local setup = function(opts)
  -- if opts.colorscheme ~= nil then
  --   vim.cmd('colorscheme ' .. opts.colorscheme)
  -- end

  require 'config.plugins'
  require 'config.settings'

  require 'config.autocmds'
  require 'config.functions'
  require 'config.keymaps'
  require 'config.theme'
  require 'config.tmux'

  -- plugin configs
  require 'plugins.bufferline'
  require 'plugins.comment'
  require 'plugins.diffview'
  require 'plugins.gitsigns'
  require 'plugins.indent-blankline'
  require 'plugins.lsp'
  require 'plugins.lualine'
  require 'plugins.mini'
  require 'plugins.navigator'
  require 'plugins.neoscroll'
  require 'plugins.null-ls'
  require 'plugins.nvim-tree'
  require 'plugins.nvim-treesitter'
  require 'plugins.telescope'
  require 'plugins.treesj'
  require 'plugins.trouble'
end

-- called on initial startup
setup { colorscheme = 'minischeme' }

-- can be called later to reload config
vim.api.nvim_create_user_command('ChangeTheme', function(opts)
  local setup_opts = {}
  if opts.args ~= '' then
    setup_opts = { colorscheme = opts.fargs[1] }
  end
  setup(setup_opts)
end, { complete = 'color', nargs = '*' })
