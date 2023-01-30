local function bind(op, outer_opts)
  outer_opts = outer_opts or { noremap = true, silent = true }
  return function(lhs, rhs, opts)
    opts = vim.tbl_extend('force', outer_opts, opts or {})
    vim.keymap.set(op, lhs, rhs, opts)
  end
end

local nnoremap = bind 'n'
local vnoremap = bind 'v'
local opts = { noremap = true, silent = true }

-- TODO refactor remaps to be native lua, maybe get rid of keymap?

vim.keymap.set({ 'n', 'v' }, '<leader>bd', '<cmd>bdelete<cr>', opts)

-- \V - very nomagic
-- search with the contents of 0 (yank) register 
nnoremap('<leader>/y', '/\\V<C-r>0<cr>')

-- find last search register and replace
nnoremap('<leader>ra', ':%s/\\V<C-r>///gI<left><left><left>')
vnoremap('<leader>ra', ':s/\\V<C-r>///gI<left><left><left>')

-- append and prepend selected lines
vnoremap('<leader>lp', ':s/^//|noh<left><left><left><left><left>')
vnoremap('<leader>la', ':s/$//|noh<left><left><left><left><left>')

-- move current line up and down
nnoremap('<M-j>', ':m .+1<CR>==')
nnoremap('<M-k>', ':m .-2<CR>==')

-- move selected line(s) up and down
vim.keymap.set('v', '<M-j>', ":m '>+1 <Home>silent<End><CR>gv=gv")
vim.keymap.set('v', '<M-k>', ":m '<-2 <Home>silent<End><CR>gv=gv")

-- yank to system clipboard
nnoremap('<leader>Y', '"+y$')
vim.keymap.set({ 'n', 'v' }, '<leader>y', '"+y', opts)

-- delete, change, put to black hole register
vim.keymap.set({ 'n', 'v' }, '<leader>xd', '"_d', opts)
vim.keymap.set({ 'n', 'v' }, '<leader>xc', '"_c', opts)
vim.keymap.set({ 'x' }, '<leader>xp', '"_dP', opts)

--[[ WINDOWS ]]
nnoremap('<C-h>', '<cmd>wincmd h<cr>')
nnoremap('<C-l>', '<cmd>wincmd l<cr>')
nnoremap('<C-j>', '<cmd>wincmd j<cr>')
nnoremap('<C-k>', '<cmd>wincmd k<cr>')

nnoremap('<leader>ww', '<cmd>vertical resize +20<cr>')
nnoremap('<leader>wn', '<cmd>vertical resize -20<cr>')
nnoremap('<leader>wt', '<cmd>resize +8<cr>')
nnoremap('<leader>ws', '<cmd>resize -8<cr>')

-- stop using arrow keys!!!
nnoremap('<up>', '<>', opts)
nnoremap('<down>', '<>', opts)
nnoremap('<left>', '<>', opts)
nnoremap('<right>', '<>', opts)

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- center cursor when moving through search results
vim.keymap.set({ 'n' }, 'n', 'nzz', { silent = true })
vim.keymap.set({ 'n' }, 'N', 'Nzz', { silent = true })

vim.keymap.set('n', '<c-_>', '<cmd>nohls<CR>', opts)
-- clear hl when starting a new search
vim.keymap.set('n', '/', '<cmd>nohls<cr>/', {})

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

vim.keymap.set('n', ']l', '<cmd>cnext<CR>', opts)
vim.keymap.set('n', '[l', '<cmd>cprevious<CR>', opts)

-- always paste from yank register at matching indent level
-- vim.keymap.set({'n', 'x'}, 'p', '"0]p', {})
-- vim.keymap.set({'n', 'x'}, 'P', '"0[p', {})

-- always paste at matching indent level
vim.keymap.set({ 'n', 'x' }, 'p', ']p', {})
vim.keymap.set({ 'n', 'x' }, 'P', '[p', {})
