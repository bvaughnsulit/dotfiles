local function augroup(name) return vim.api.nvim_create_augroup('user_' .. name, { clear = true }) end

vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function() vim.highlight.on_yank({ timeout = 500, higroup = 'visual' }) end,
  group = augroup('hl_on_yank'),
  desc = 'hl on yank',
})

vim.api.nvim_create_autocmd('BufEnter', {
  callback = function()
    vim.opt.formatoptions:remove('c')
    vim.opt.formatoptions:remove('r')
    vim.opt.formatoptions:remove('o')
  end,
  group = augroup('format_options'),
  desc = 'prevent comments when creating newline before or after comment',
})

vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = '*',
  callback = function() vim.cmd([[hi! default link MiniCursorword LspReferenceText]]) end,
  desc = 'overwrite mini cursorword highlight group',
})

vim.api.nvim_create_autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
  group = augroup('checktime'),
  command = 'checktime',
})

-- markdown-specific options
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'markdown' },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
    vim.opt_local.conceallevel = 3
  end,
})
