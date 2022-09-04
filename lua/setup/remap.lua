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
local opts = { noremap=true, silent=true }

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

nnoremap(
  '<leader>b',
  '<cmd>Telescope buffers<cr>'
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
  '<leader>e',
  '<cmd>NvimTreeToggle<cr>'
)

nnoremap(
  '<C-h>',
  '<cmd>bprev<cr>'
)

nnoremap(
  '<C-l>',
  '<cmd>bnext<cr>'
)

vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)


-- ** lsp stuff currently moved to lsp.lua **
--
-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
-- local on_attach = function(client, bufnr)
--   -- Enable completion triggered by <c-x><c-o>
--   vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
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
