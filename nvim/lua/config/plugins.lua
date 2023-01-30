local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = ' '
require('lazy').setup({
  {
    'echasnovski/mini.nvim',
    lazy = false,
    priority = 1000,
    config = function ()
      vim.cmd('colorscheme minischeme')
    end

  }, --themes
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
  },
  'nvim-treesitter/nvim-treesitter-context',
  {
    'nvim-treesitter/playground',
    -- config = function()
    --   require('playground').setup { playground = {} }
    -- end,
  },
  'JoosepAlviste/nvim-ts-context-commentstring',
  'nvim-treesitter/nvim-treesitter-textobjects', -- LSP
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
    },
  },
  'hrsh7th/nvim-cmp',
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-path',
  'hrsh7th/cmp-cmdline',
  'L3MON4D3/LuaSnip',
  'saadparwaiz1/cmp_luasnip',
  'rafamadriz/friendly-snippets',
  'ray-x/lsp_signature.nvim',
  'hrsh7th/cmp-nvim-lua',
  {
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup()
    end,
  },
  'jose-elias-alvarez/null-ls.nvim',
  'marko-cerovac/material.nvim',
  'https://gitlab.com/__tpb/monokai-pro.nvim',
  'sainnhe/gruvbox-material',
  'ishan9299/nvim-solarized-lua',
  'shaunsingh/solarized.nvim',
  { 'catppuccin/nvim', name = 'catppuccin' },
  'folke/tokyonight.nvim',
  'EdenEast/nightfox.nvim',
  'ofirgall/ofirkai.nvim',
  'nyoom-engineering/oxocarbon.nvim',
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
  },
  { 'numToStr/Comment.nvim' },
  {
    'folke/trouble.nvim',
    dependencies = 'nvim-tree/nvim-web-devicons',
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons', lazy = true },
  },
  'tpope/vim-fugitive',
  'lewis6991/gitsigns.nvim',
  { 'sindrets/diffview.nvim', dependencies = 'nvim-lua/plenary.nvim' },
  {
    'nvim-telescope/telescope.nvim',
    version = '0.1.0',
    dependencies = { { 'nvim-lua/plenary.nvim' } },
  },
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  'lukas-reineke/indent-blankline.nvim',
  {
    'windwp/nvim-autopairs',
    config = function()
      require('nvim-autopairs').setup {}
    end,
  },
  {
    'akinsho/bufferline.nvim',
    version = 'v3.*',
    dependencies = 'nvim-tree/nvim-web-devicons',
  }, -- , fork of karb94/neoscroll.nvim until time-scale branch is merged to main -- , 'karb94/neoscroll.nvim'
  {
    'bvaughnsulit/neoscroll.nvim',
    branch = 'time-scale',
  },
  { 'Wansmer/treesj', dependencies = { 'nvim-treesitter' } },
  'numToStr/Navigator.nvim',
}, {})
