local function bind(op, outer_opts)
    outer_opts = outer_opts or { noremap = true, silent = true }
    return function(lhs, rhs, opts)
        opts = vim.tbl_extend("force",
            outer_opts,
            opts or {}
        )
        vim.keymap.set(op, lhs, rhs, opts)
    end
end

local nnoremap = bind("n")
local vnoremap = bind("v")
local inoremap = bind("i")
local opts = { noremap=true, silent=true, }

-- TODO move plugin specific maps to own files
-- TODO refactor remaps to be native lua, maybe get rid of keymap? 

nnoremap(
  '<leader>mm',
  [[<Cmd>lua require('material.functions').toggle_style()<CR>]],
  { noremap = true, silent = true }
)

nnoremap(
  '<C-p>',
  [[<cmd>lua require('telescope.builtin').find_files({hidden=true})<cr>]]
)

nnoremap(
  '<C-f>',
  [[<cmd>lua require('telescope.builtin').live_grep()<cr>]]
)


-- buffer dropdown
nnoremap(
  '<C-b>',
  function()
    require('telescope.builtin').buffers(
      require('telescope.themes').get_dropdown{
        sort_mru = true,
        bufnr_width = 5,
        ignore_current_buffer = true,
        initial_mode = "normal",
        path_display = {'tail'},
        -- path_display = function(opts, path)
        --   local tail = require("telescope.utils").path_tail(path)
        --   return string.format("%s (%s)", tail, path)
        -- end,
        layout_config = { anchor = "N" }
      })
  end
)


vim.keymap.set({'n','v'}, '<leader>bd', '<cmd>bdelete<cr>', opts)

vim.keymap.set('n', '<leader>/f', function()
  require('telescope.builtin').current_buffer_fuzzy_find(
    require('telescope.themes').get_dropdown {
      layout_config = {
        anchor = "S",
        width = 0.7,
      },
    })
end, { desc = '[/] Fuzzily search in current buffer]' })

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
  '<leader>do',
  function ()
    require('telescope.builtin').diagnostics(
      require('telescope.themes').get_dropdown {
        initial_mode = 'normal',
        no_sign = false,
        layout_config = {
          anchor = "S",
          mirror = 'false',
          width = 0.7,
        },
      }
    )
  end
)


-- write and source current file
nnoremap(
  '<leader>xx',
  function ()
    vim.cmd('w')
    vim.cmd('so %')
  end
)


nnoremap('<leader>/y', '/\\V<C-r>0<cr>')
-- find last search register and replace
nnoremap('<leader>ra', ':%s/\\V<C-r>///gI<left><left><left>')
vnoremap('<leader>ra', ':s/\\V<C-r>///gI<left><left><left>')

-- append and prepend selected lines
vnoremap('<leader>lp', ':s/^//|noh<left><left><left><left><left>')
vnoremap('<leader>la', ':s/$//|noh<left><left><left><left><left>')

-- move lines up and down
nnoremap ('<M-j>', ':m .+1<CR>==')
nnoremap ('<M-k>', ':m .-2<CR>==')
vnoremap ("<M-j>", ":m '>+1<CR>gv=gv")
vnoremap ("<M-k>", ":m '<-2<CR>gv=gv")

-- yank to system clipboard
nnoremap ('<leader>Y', '\"+y$')
vim.keymap.set({'n','v'}, '<leader>y', '\"+y', opts)

-- delete, change, put to black hole register
vim.keymap.set({'n','v'}, '<leader>xd', '\"_d', opts)
vim.keymap.set({'n','v'}, '<leader>xc', '\"_c', opts)
vim.keymap.set({'x'}, '<leader>xp', '\"_dP', opts)


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

-- customize scroll value base on height of window
-- not needed with smooth scroll
-- vim.keymap.set('n', '<c-u>', "(winheight(0) / 4) .. '<c-u>'", { expr = true, silent = true })
-- vim.keymap.set('n', '<c-d>', "(winheight(0) / 4) .. '<c-d>'", { expr = true, silent = true })

-- stop using arrow keys!!!
nnoremap('<up>','<>', opts)
nnoremap('<down>','<>', opts)
nnoremap('<left>','<>', opts)
nnoremap('<right>','<>', opts)


vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

vim.keymap.set('n', '<c-_>', '<cmd>nohls<CR>', opts)

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

vim.keymap.set('n', ']l', '<cmd>cnext<CR>', opts)
vim.keymap.set('n', '[l', '<cmd>cprevious<CR>', opts)

vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)

-- always paste from yank register at matching indent level
-- vim.keymap.set({'n', 'x'}, 'p', '"0]p', {})
-- vim.keymap.set({'n', 'x'}, 'P', '"0[p', {})

-- always paste at matching indent level
vim.keymap.set({'n', 'x'}, 'p', ']p', {})
vim.keymap.set({'n', 'x'}, 'P', '[p', {})

