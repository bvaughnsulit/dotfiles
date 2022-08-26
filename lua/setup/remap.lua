local nnoremap = require("setup.keymap").nnoremap

-- change theme
nnoremap(
  '<leader>mm',
  [[<Cmd>lua require('material.functions').toggle_style()<CR>]],
  { noremap = true, silent = true }
)

-- coc
vim.cmd([[
  inoremap <silent><expr> <cr> coc#pum#visible() ? coc#_select_confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
  inoremap <expr> <cr> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"
  inoremap <expr> <tab> coc#pum#visible() ? coc#pum#confirm() : "\<tab>"
]])

-- telescope
nnoremap(
  '<leader>ff',
  [[<cmd>lua require('telescope.builtin').find_files()<cr>]]
)
nnoremap(
  '<C-p>',
  [[<cmd>lua require('telescope.builtin').find_files()<cr>]]
)

nnoremap(
  '<C-f>',
  [[<cmd>lua require('telescope.builtin').live_grep()<cr>]]
)

nnoremap(
  '<leader>gr',
  [[<cmd>lua require('telescope.builtin').live_grep()<cr>]]
)
