vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_ruby_provider = 0

vim.opt.number = true
vim.opt.mouse = "a"
vim.opt.mousemodel = "extend"
vim.opt.updatetime = 200
vim.opt.tabstop = 4
-- vim.opt.softtabstop = 4
vim.opt.shiftwidth = 0
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
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undo"
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.wrap = false
vim.opt.colorcolumn = "0"
vim.opt.signcolumn = "yes"
vim.opt.showtabline = 0
vim.opt.termguicolors = true
vim.opt.swapfile = false
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.timeoutlen = 1000
vim.opt.hlsearch = true
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.cursorline = true
vim.opt.cursorlineopt = "line"
vim.opt.cmdheight = 0
vim.opt.diffopt = "filler,vertical,closeoff"
vim.opt.fillchars = {
    diff = "╱",
    fold = "·",
    foldopen = "",
    foldclose = "",
    foldsep = " ",
    eob = " ",
    msgsep = "╌",
}
vim.opt.autoread = true
vim.opt.confirm = true
vim.opt.laststatus = 3
vim.opt.pumheight = 10
vim.opt.pumblend = 0
vim.opt.winblend = 0
vim.opt.shiftround = true
vim.opt.wildmode = "longest:full,full"
vim.opt.conceallevel = 0
vim.opt.sessionoptions = {
    "buffers",
    "tabpages",
    "winsize",
    "help",
    "globals",
    "skiprtp",
    "folds",
}
vim.opt.list = false
-- vim.opt.listchars = 'multispace:·,nbsp:·,trail:·'
vim.opt.grepprg = "rg --vimgrep"
vim.opt.sidescrolloff = 8
vim.opt.spelllang = { "en" }
vim.opt.splitkeep = "screen"
vim.opt.clipboard = ""
vim.opt.relativenumber = true
vim.opt.shortmess:append({ c = true, C = true })
vim.opt.showmode = false
vim.opt.undolevels = 10000
vim.opt.winminwidth = 5
vim.opt.smoothscroll = true
vim.opt.jumpoptions = "view"
vim.opt.virtualedit = "block"
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldtext = "getline(v:foldstart) .. ' '"
vim.opt.foldcolumn = "1"

vim.g.markdown_recommended_style = 0
vim.g.autoformat = true
-- vim.g.deprecation_warnings = false
-- vim.g.root_spec = { 'lsp', { '.git', 'lua' }, 'cwd' }
-- vim.opt.formatexpr = "v:lua.require'lazyvim.util'.format.formatexpr()"
-- vim.opt.formatoptions = 'jcroqlnt' -- tcqj
