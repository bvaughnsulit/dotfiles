require('cinnamon').setup {
  default_keymaps = false,
  extra_keymaps = false,
  extended_keymaps = false,
  override_keymaps = true,

  max_length = 50,
  scroll_limit = 999,

  always_scroll = true,    -- Scroll the cursor even when the window hasn't scrolled.
  centered = true,          -- Keep cursor centered in window when using window scrolling.
  default_delay = 4,        -- The default delay (in ms) between each line when scrolling.
  horizontal_scroll = true, -- Enable smooth horizontal scrolling when view shifts left or right.
}


vim.keymap.set({ 'n', 'x' }, '<C-u>', "<Cmd>lua Scroll('<C-u>', 1, 1)<CR>")
vim.keymap.set({ 'n', 'x' }, '<C-d>', "<Cmd>lua Scroll('<C-d>', 1, 1)<CR>")

-- Start/end of file and line number movements:
vim.keymap.set({ 'n', 'x' }, 'gg', "<Cmd>lua Scroll('gg')<CR>")
vim.keymap.set({ 'n', 'x' }, 'G', "<Cmd>lua Scroll('G', 0, 1)<CR>")

-- Previous/next search result:
vim.keymap.set('n', 'n', "<Cmd>lua Scroll('n', 1)<CR>")
vim.keymap.set('n', 'N', "<Cmd>lua Scroll('N', 1)<CR>")
vim.keymap.set('n', '*', "<Cmd>lua Scroll('*', 1)<CR>")
vim.keymap.set('n', '#', "<Cmd>lua Scroll('#', 1)<CR>")
vim.keymap.set('n', 'g*', "<Cmd>lua Scroll('g*', 1)<CR>")
vim.keymap.set('n', 'g#', "<Cmd>lua Scroll('g#', 1)<CR>")

-- Previous/next cursor location:
vim.keymap.set('n', '<C-o>', "<Cmd>lua Scroll('<C-o>', 1)<CR>")
vim.keymap.set('n', '<C-i>', "<Cmd>lua Scroll('1<C-i>', 1)<CR>")

-- Screen scrolling:
vim.keymap.set('n', 'zz', "<Cmd>lua Scroll('zz', 0, 1)<CR>")
vim.keymap.set('n', 'zt', "<Cmd>lua Scroll('zt', 0, 1)<CR>")
vim.keymap.set('n', 'zb', "<Cmd>lua Scroll('zb', 0, 1)<CR>")
vim.keymap.set('n', 'z.', "<Cmd>lua Scroll('z.', 0, 1)<CR>")
vim.keymap.set('n', 'z<CR>', "<Cmd>lua Scroll('zt^', 0, 1)<CR>")
vim.keymap.set('n', 'z-', "<Cmd>lua Scroll('z-', 0, 1)<CR>")
vim.keymap.set('n', 'z^', "<Cmd>lua Scroll('z^', 0, 1)<CR>")
vim.keymap.set('n', 'z+', "<Cmd>lua Scroll('z+', 0, 1)<CR>")
vim.keymap.set('n', '<C-y>', "<Cmd>lua Scroll('<C-y>', 0, 1)<CR>")
