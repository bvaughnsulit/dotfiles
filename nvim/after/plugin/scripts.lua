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


-- [[ Highlight on yank ]]
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank({ timeout = 700, higroup = 'visual' })
  end,
  group = highlight_group,
  pattern = '*',
})
