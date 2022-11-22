-- packer plugins file: save, source, take snapshot, sync
vim.api.nvim_create_user_command(
  'PluginUpdate',
  function ()
    vim.cmd('w')
    vim.cmd('source %')
    vim.cmd('PackerSnapshot ' .. os.date("snapshot-%Y-%m-%dT%H.%M.%S"))
    vim.cmd('PackerSync')
  end, {}
)

vim.api.nvim_create_user_command('Gho', function() vim.cmd('!gh browse') end, {})


-- [[ Highlight on yank ]]
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank({ timeout = 500, higroup = 'visual' })
  end,
  group = highlight_group,
  pattern = '*',
})

vim.keymap.set('n', '<leader>rr', "<cmd>so '$HOME/.config/nvim/init.lua<cr>'", {})
