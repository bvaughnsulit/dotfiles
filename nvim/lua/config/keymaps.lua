local utils = require('config.utils')

local map = function(mode, lhs, rhs, opts)
  opts = vim.tbl_deep_extend('force', { remap = false, silent = true }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

map({ 'n', 'v' }, '<leader>bd', '<cmd>bdelete<cr>', {})

-- \V - very nomagic
map('n', '<leader>/y', '/\\V<C-r>+<cr>', { desc = 'search with contents of + register' })

map('n', '<leader>ra', ':%s/\\V<C-r>///gI<left><left><left>')
map(
  'v',
  '<leader>ra',
  ':s/\\V<C-r>///gI<left><left><left>',
  { desc = 'replace with last search in selected area' }
)

map(
  'v',
  '<leader>lp',
  ':s/^//|noh<left><left><left><left><left>',
  { desc = 'append selected lines' }
)
map(
  'v',
  '<leader>la',
  ':s/$//|noh<left><left><left><left><left>',
  { desc = 'prepend selected lines' }
)

-- always yank to system clipboard
map('n', 'Y', '"+y$')
map({ 'n', 'v' }, 'y', '"+y', {})

-- delete, change, put to black hole register
map({ 'n', 'v' }, '<leader>xd', '"_d', {})
map({ 'n', 'v' }, '<leader>xc', '"_c', {})
map({ 'x' }, '<leader>p', 'p', { desc = 'hello' })
map({ 'x' }, 'p', '"_dP', {})

--[[ WINDOWS ]]
map({ 'n', 't' }, '<C-h>', '<cmd>wincmd h<cr>')
map({ 'n', 't' }, '<C-l>', '<cmd>wincmd l<cr>')
map({ 'n', 't' }, '<C-j>', '<cmd>wincmd j<cr>')
map({ 'n', 't' }, '<C-k>', '<cmd>wincmd k<cr>')

-- stop using arrow keys!!!
map('n', '<up>', '<>', {})
map('n', '<down>', '<>', {})
map('n', '<left>', '<>', {})
map('n', '<right>', '<>', {})

map({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

map('n', '<C-o>', '<C-o>zz')
map('n', '<C-i>', '<C-i>zz')
map('n', '<C-d>', '<C-d>zz')
map('n', '<C-u>', '<C-u>zz')

map({ 'i', 'n' }, '<esc>', '<cmd>noh<cr><esc>', {})

-- Remap for dealing with word wrap
map('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

map('n', ']l', '<cmd>cnext<CR>', {})
map('n', '[l', '<cmd>cprevious<CR>', {})

-- stay in visual mode after indenting
map('v', '<', '<gv')
map('v', '>', '>gv')

map(
  'n',
  '<cr>',
  "<Cmd>call append(line('.') - 1, repeat([''], v:count1))<CR>",
  { desc = 'Put empty line above', silent = true }
)

map('x', '/', '<esc>/\\%V', { silent = false, desc = 'Search inside visual selection' })

map('n', '<S-left>', '<cmd>vertical resize -5<cr>', {})
map('n', '<S-right>', '<cmd>vertical resize +5<cr>', {})
map('n', '<s-up>', '<cmd>resize +2<cr>', {})
map('n', '<s-down>', '<cmd>resize -2<cr>', {})

-- UNDO BREAKPOINTS
map('i', ',', ',<c-g>u')
map('i', '.', '.<c-g>u')
map('i', ';', ';<c-g>u')
map('i', '<cr>', '<cr><c-g>u')

map('n', '<leader>w', '<cmd>w<cr>', { desc = ':w' })
map('n', '<leader>qq', '<cmd>qa<cr>', { desc = 'Quit all' })
map('n', '<leader>QQ', '<cmd>qa!<cr>', { desc = 'Force Quit all' })
map('n', '<leader>qw', '<cmd>wqa<cr>', { desc = 'Quit and save all' })

map('n', '<leader>xx', function()
  vim.cmd('w')
  vim.cmd('so %')
end, { desc = 'Save and source current file' })

utils.create_cmd_and_map(
  'ToggleWrap',
  '<leader>tw',
  function() vim.opt.wrap = not vim.opt.wrap:get() end,
  'Toggle line wrap'
)

utils.create_cmd_and_map('BDeleteAll', nil, function() vim.cmd('%bd') end, 'Delete All Buffers')

utils.create_cmd_and_map(
  'RelativeNumbersToggle',
  '<leader>tn',
  function() vim.opt.relativenumber = not vim.opt.relativenumber:get() end,
  'Toggle Relative Numbers'
)

utils.create_cmd_and_map(
  'CopyPathToClipboard',
  nil,
  function() utils.copy_gh_file_url() end,
  'Copy Relative Filepath to Clipboard'
)

utils.create_cmd_and_map(
  'OpenFileInGitHub',
  nil,
  function() utils.open_file_in_gh() end,
  'Open File in Github'
)

utils.create_cmd_and_map(
  'OpenFileInVSCode',
  nil,
  function() utils.open_file_in_vscode() end,
  'Open File in VS Code'
)

utils.create_cmd_and_map(
  'OpenRepoInGitHub',
  nil,
  function() utils.open_repo_in_gh() end,
  'Open Github Repo in Browser'
)

utils.create_cmd_and_map(
  'EnableDiagnosticsCurrentBuffer',
  nil,
  function() vim.diagnostic.enable(0) end
)

utils.create_cmd_and_map(
  'DisableDiagnosticsCurrentBuffer',
  nil,
  function() vim.diagnostic.disable(0) end
)

-- utils.create_cmd_and_map(nil, nil, function() vim.cmd('copen') end, 'Open Quickfix')
-- utils.create_cmd_and_map(nil, nil, function() vim.cmd('lopen') end, 'Open Location list')

utils.create_cmd_and_map(nil, '<leader><tab>c', function() vim.cmd('tabnew') end, 'New Tab')
utils.create_cmd_and_map(nil, '<leader><tab>x', function() vim.cmd('tabclose') end, 'Close Tab')
utils.create_cmd_and_map(nil, '<leader><tab>n', function() vim.cmd('tabnext') end, 'Next Tab')
utils.create_cmd_and_map(nil, '<leader><tab>p', function() vim.cmd('tabp') end, 'Previous Tab')

utils.create_cmd_and_map(nil, { mode = { 't' }, lhs = '<esc><esc>' }, '<c-\\><c-n>')
utils.create_cmd_and_map(
  'InspectHighlights',
  nil,
  function() vim.show_pos() end,
  'Inspect highlights under cursor'
)
