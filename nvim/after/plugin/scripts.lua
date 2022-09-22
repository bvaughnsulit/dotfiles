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


-- auto toggle hlsearch when entering and exiting cmd mode
local auto_clear_hls = vim.api.nvim_create_augroup('auto-clear', { clear = true})
vim.api.nvim_create_autocmd('CmdlineLeave', {
  callback = function()
    vim.opt.hlsearch = false
  end,
  group = auto_clear_hls,
  pattern = '*'
})
vim.api.nvim_create_autocmd('CmdlineEnter', {
  callback = function()
    vim.opt.hlsearch = true
  end,
  group = auto_clear_hls,
  pattern = '*'
})
