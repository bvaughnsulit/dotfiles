-- packer plugins file: save, source, take snapshot, sync
vim.api.nvim_create_user_command(
  'UpdatePlugins',
  function ()
    vim.cmd('w')
    vim.cmd('source %')
    vim.cmd('PackerSnapshot ' .. os.date("snapshot-%Y-%m-%dT%H.%M.%S"))
    vim.cmd('PackerSync')
  end, {}
)
