local setup = function(opts)
  -- if opts.colorscheme ~= nil then
  --   vim.cmd('colorscheme ' .. opts.colorscheme)
  -- end

  require 'config.lazy'
  require 'config.settings'

  require 'config.autocmds'
  require 'config.functions'
  require 'config.keymaps'
  -- require 'config.theme'
  require 'config.tmux'
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
