local utils = require 'config.utils'
local map = utils.map
local cmd = utils.create_cmd

map({ 'n', 'v' }, '<leader>bd', '<cmd>bdelete<cr>', {})

-- \V - very nomagic
-- search with the contents of 0 (yank) register
map('n', '<leader>/y', '/\\V<C-r>0<cr>')

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
map({ 'x' }, '<leader>xp', '"_dP', {})

--[[ WINDOWS ]]
map('n', '<C-h>', '<cmd>wincmd h<cr>')
map('n', '<C-l>', '<cmd>wincmd l<cr>')
map('n', '<C-j>', '<cmd>wincmd j<cr>')
map('n', '<C-k>', '<cmd>wincmd k<cr>')

-- stop using arrow keys!!!
map('n', '<up>', '<>', {})
map('n', '<down>', '<>', {})
map('n', '<left>', '<>', {})
map('n', '<right>', '<>', {})

map({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- center cursor when moving through search results
-- map({ 'n' }, 'n', 'nzz', { silent = true })
-- map({ 'n' }, 'N', 'Nzz', { silent = true })

-- clear hl with esc
map({ 'i', 'n' }, '<esc>', '<cmd>noh<cr><esc>', {})
map('n', '<c-_>', '<cmd>nohls<CR>', {})

-- Remap for dealing with word wrap
map('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

map('n', ']l', '<cmd>cnext<CR>', {})
map('n', '[l', '<cmd>cprevious<CR>', {})

-- i don't think these work right...
-- always paste from yank register at matching indent level
-- map({'n', 'x'}, 'p', '"0]p', {})
-- map({'n', 'x'}, 'P', '"0[p', {})
-- always paste at matching indent level
-- map({ 'n', 'x' }, 'p', ']p', {})
-- map({ 'n', 'x' }, 'P', '[p', {})

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

map({ 'i', 'v', 'n', 's' }, '<C-s>', '<cmd>w<cr><esc>', { desc = 'Save file' })
map('n', '<leader>qq', '<cmd>qa<cr>', { desc = 'Quit all' })
map('n', '<leader>wq', '<cmd>wqa<cr>', { desc = 'Quit and save all' })

map('n', '<leader>xx', utils.save_and_source, { desc = 'Save and source current file' })

cmd('Gho', utils.gh_browse)
cmd('RelativeNumbersToggle', utils.toggle_rel_num)
cmd('BDeleteAll', utils.delete_all_bufs)
