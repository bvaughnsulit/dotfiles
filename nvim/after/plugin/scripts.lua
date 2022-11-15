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

--
-- TMUX COMMANDS
-- 

-- open and focus tmux pane
vim.keymap.set(
  'n',
  '<C-\\>',
  function()
    -- if window is zoomed, unzoom, then move focus to right pane 
    -- if no addtl pane exists (not zoomed, and rightmost), create and focus it
    vim.cmd([[ silent
      \ !tmux if-shell -F
        \ '\#{?window_zoomed_flag,1,0}' 
        \ 'resize-pane -Z'
        \ "if-shell -F
          \ '\#{?pane_at_right,1,0}' 
          \ 'split-window -h -l 25\% ; select-pane -R'
          \ '' " 
        \ ';' 
      \ select-pane -R
    ]])
  end,
  { silent = true }
)

-- repeat last command in tmux pane
vim.keymap.set(
  'n',
  '<leader>!!',
  function()
    -- if zoomed, unzoom, then repeat last command in top right pane
    vim.cmd([[ silent
      \ !tmux if-shell -F
        \ '\#{?window_zoomed_flag,1,0}'
        \ 'resize-pane -Z'
        \ '' ';'
      \ send-keys -t {top-right} '\!\!' Enter 
    ]])
  end,
  { silent = true }
)

-- wincmd o also zooms tmux pane
vim.keymap.set(
  'n',
  '<c-w>o',
  function()
    -- default behavior 
    vim.cmd('only')
    -- if unzoomed, zoom
    vim.cmd([[ silent
      \ !tmux if-shell -F
        \ '\#{?window_zoomed_flag,1,0}'
        \ ''
        \ 'resize-pane -Z'
    ]])
  end,
  { silent = true }
)
