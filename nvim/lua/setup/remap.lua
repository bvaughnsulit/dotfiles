local function bind(op, outer_opts)
    outer_opts = outer_opts or {noremap = true}
    return function(lhs, rhs, opts)
        opts = vim.tbl_extend("force",
            outer_opts,
            opts or {}
        )
        vim.keymap.set(op, lhs, rhs, opts)
    end
end

local nnoremap = bind("n")
local opts = { noremap=true, silent=true, }

-- TODO refactor remaps to be native lua, maybe get rid of keymap? 

nnoremap(
  '<leader>mm',
  [[<Cmd>lua require('material.functions').toggle_style()<CR>]],
  { noremap = true, silent = true }
)

nnoremap(
  '<leader>ff',
  [[<cmd>lua require('telescope.builtin').find_files()<cr>]]
)

nnoremap(
  '<C-p>',
  [[<cmd>lua require('telescope.builtin').find_files({hidden=true})<cr>]]
)

nnoremap(
  '<C-f>',
  [[<cmd>lua require('telescope.builtin').live_grep()<cr>]]
)

nnoremap(
  '<leader>gr',
  [[<cmd>lua require('telescope.builtin').live_grep()<cr>]]
)

-- buffer dropdown
nnoremap(
  '<leader>b',
  function()
    return require('telescope.builtin').buffers(
      require('telescope.themes').get_dropdown{
        sort_mru = true,
        initial_mode = 'normal',
        ignore_current_buffer = true,
        layout_config = { anchor = "N" }
      })
  end
)

nnoremap(
  '<leader>o',
  '<cmd>Telescope oldfiles<cr>'
)

nnoremap(
  '<leader>km',
  '<cmd>Telescope keymaps<cr>'
)

nnoremap(
  '<leader>?',
  '<cmd>Telescope help_tags<cr>'
)

nnoremap(
  '<leader>ee',
  '<cmd>NvimTreeToggle<cr>'
)


nnoremap(
  '<leader>do',
  '<cmd>TroubleToggle<cr>'
)

-- write and source current file
nnoremap(
  '<leader>xx',
  function ()
    vim.cmd('w')
    vim.cmd('so %')
  end
)



--[[
    
    WINDOWS

--]]

nnoremap('<C-h>', '<cmd>wincmd h<cr>')
nnoremap('<C-l>', '<cmd>wincmd l<cr>')
nnoremap('<C-j>', '<cmd>wincmd j<cr>')
nnoremap('<C-k>', '<cmd>wincmd k<cr>')

nnoremap('<leader>ww', '<cmd>vertical resize +20<cr>')
nnoremap('<leader>wn', '<cmd>vertical resize -20<cr>')
nnoremap('<leader>wt', '<cmd>resize +8<cr>')
nnoremap('<leader>ws', '<cmd>resize -8<cr>')



--[[

  TERMINAL

--]]

nnoremap(
  [[<C-\>]],
  '<cmd>ToggleTermToggleAll<cr>'
)

nnoremap(
  '<leader>t2',
  '<cmd>ToggleTerm 2<cr>'
)

nnoremap(
  '<leader>t3',
  '<cmd>ToggleTerm 3<cr>'
)

-- stop using arrow keys!!!
nnoremap('<up>','<>', opts)
nnoremap('<down>','<>', opts)
nnoremap('<left>','<>', opts)
nnoremap('<right>','<>', opts)


vim.keymap.set('n', ']l', '<cmd>cnext<CR>', opts)
vim.keymap.set('n', '[l', '<cmd>cprevious<CR>', opts)

vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)


vim.keymap.set('t', [[<C-\>]], '<cmd>ToggleTermToggleAll<cr>' , {})
vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], {})
vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
vim.keymap.set('n', '<leader>!!', '<cmd>TermExec cmd=!!<cr>', opts)

-- always paste from yank register at matching indent level
-- vim.keymap.set({'n', 'x'}, 'p', '"0]p', {})
-- vim.keymap.set({'n', 'x'}, 'P', '"0[p', {})

-- always paste at matching indent level
vim.keymap.set({'n', 'x'}, 'p', ']p', {})
vim.keymap.set({'n', 'x'}, 'P', '[p', {})

-- ** lsp stuff currently moved to lsp.lua **
--
-- local on_attach = function(client, bufnr)
--   local bufopts = { noremap=true, silent=true, buffer=bufnr }
--   vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
--   vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
--   vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
--   vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
--   vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
--   vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
--   vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
--   vim.keymap.set('n', '<space>wl', function()
--     print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
--   end, bufopts)
--   vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
--   vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
--   vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
--   vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
--   vim.keymap.set('n', '<space>f', vim.lsp.buf.formatting, bufopts)
-- end
