-- packer plugins file: save, source, take snapshot, sync
vim.api.nvim_create_user_command('PluginUpdate', function()
	vim.cmd 'w'
	vim.cmd 'source %'
	vim.cmd('PackerSnapshot ' .. os.date 'snapshot-%Y-%m-%dT%H.%M.%S')
	vim.cmd 'PackerSync'
end, {})

vim.api.nvim_create_user_command('Gho', function()
	vim.cmd '!gh browse'
end, {})

vim.keymap.set('n', '<leader>rr', "<cmd>so '$HOME/.config/nvim/init.lua<cr>'", {})

-- write and source current file
vim.keymap.set('n', '<leader>xx', function()
  vim.cmd 'w'
  vim.cmd 'so %'
end)
