local setup = function(opts)
  if opts.colorscheme ~= nil then
    vim.cmd('colorscheme ' .. opts.colorscheme)
  end

  require 'setup.settings'
  require 'setup.theme'
  require 'setup.keymaps'
  require 'setup.functions'
  require 'setup.tmux'
  require 'setup.plugins'

  -- plugin configs
  require 'setup.config.bufferline'
  require 'setup.config.null-ls'
  require 'setup.config.neoscroll'
  require 'setup.config.gitsigns'
  require 'setup.config.diffview'
  require 'setup.config.indent-blankline'
  require 'setup.config.lsp'
  require 'setup.config.lualine'
  require 'setup.config.mini'
  require 'setup.config.navigator'
  require 'setup.config.nvim-tree'
  require 'setup.config.nvim-treesitter'
  require 'setup.config.telescope'
  require 'setup.config.trouble'
  require 'setup.config.comment'
end

-- called on initial startup
setup { colorscheme = 'minischeme' }

-- can be called later to reload config
vim.api.nvim_create_user_command('SourceInit', function(opts)
  local setup_opts = {}
  if opts.args ~= '' then
    setup_opts = { colorscheme = opts.fargs[1] }
  end
  setup(setup_opts)
end, { complete = 'color', nargs = '*' })
