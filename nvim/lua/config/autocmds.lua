local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function() vim.highlight.on_yank({ timeout = 500, higroup = 'visual' }) end,
  group = highlight_group,
  pattern = '*',
  desc = 'hl on yank',
})

local format_options_group = vim.api.nvim_create_augroup('FormatOptions', { clear = true })
vim.api.nvim_create_autocmd('BufEnter', {
  callback = function()
    vim.opt.formatoptions:remove('c')
    vim.opt.formatoptions:remove('r')
    vim.opt.formatoptions:remove('o')
  end,
  group = format_options_group,
  desc = 'prevent comments when creating newline before or after comment',
})

vim.api.nvim_create_autocmd('VimEnter', {
  pattern = '*',
  callback = function() require('mini.map').open() end,
})

vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = '*',
  callback = function() vim.cmd([[hi! default link MiniCursorword LspReferenceText]]) end,
  desc = 'overwrite mini cursorword highlight group',
})

local checktime_group = vim.api.nvim_create_augroup('checktime_group', { clear = true })
vim.api.nvim_create_autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
  group = checktime_group,
  command = 'checktime',
})
