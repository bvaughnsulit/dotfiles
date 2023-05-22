vim.g.mapleader = ' '
vim.g.material_style = 'deep ocean'

vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.mouse = 'a'
-- vim.opt.updatetime = 100
vim.opt.tabstop = 4
-- vim.opt.softtabstop = 4
-- vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.scrolloff = 12
vim.opt.numberwidth = 3
vim.opt.errorbells = false
vim.opt.hidden = true
vim.opt.undofile = true
vim.opt.undodir = os.getenv('HOME') .. '/.vim/undo'
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.wrap = false
vim.opt.colorcolumn = '0'
vim.opt.signcolumn = 'yes'
vim.opt.showtabline = 0
vim.opt.termguicolors = true
vim.opt.swapfile = false
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.timeoutlen = 1000
vim.opt.hlsearch = true
vim.opt.completeopt = 'menu,menuone,noselect'
vim.opt.cursorline = true
vim.opt.cursorlineopt = 'line'
vim.opt.cmdheight = 0
vim.opt.diffopt = 'filler,vertical,closeoff'
vim.opt.fillchars = 'diff:╱,fold:╌,foldopen:,foldclose:,msgsep:╌,eob: '
vim.opt.autoread = true
vim.opt.confirm = true
vim.opt.laststatus = 3
vim.opt.pumheight = 10
vim.opt.pumblend = 7
vim.opt.winblend = 7
vim.opt.shiftround = true
vim.opt.wildmode = 'longest:full,full'
vim.opt.conceallevel = 0
vim.opt.sessionoptions =
  'blank,buffers,curdir,folds,tabpages,winsize,winpos,terminal,localoptions,globals'
-- vim.opt.list = true
-- vim.opt.listchars = 'multispace:·,nbsp:·,trail:·'

-- markdown-specific options
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'markdown' },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
    vim.opt_local.conceallevel = 3
  end,
})
