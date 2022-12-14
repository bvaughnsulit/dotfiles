vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
  }
  use 'nvim-treesitter/nvim-treesitter-context'
  use {
    'nvim-treesitter/playground',
    -- config = function()
    --   require('playground').setup { playground = {} }
    -- end,
  }
  use 'JoosepAlviste/nvim-ts-context-commentstring'

  use 'nvim-treesitter/nvim-treesitter-textobjects'

  -- LSP
  use {
    'neovim/nvim-lspconfig',
    requires = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
    },
  }
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'L3MON4D3/LuaSnip'
  use 'saadparwaiz1/cmp_luasnip'
  use 'rafamadriz/friendly-snippets'
  use 'ray-x/lsp_signature.nvim'
  use 'hrsh7th/cmp-nvim-lua'
  use {
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup()
    end,
  }
  use 'jose-elias-alvarez/null-ls.nvim'

  use { 'echasnovski/mini.nvim', branch = 'stable' }

  --themes
  use 'marko-cerovac/material.nvim'
  use 'https://gitlab.com/__tpb/monokai-pro.nvim'
  use 'sainnhe/gruvbox-material'
  use 'ishan9299/nvim-solarized-lua'
  use 'shaunsingh/solarized.nvim'
  use { 'catppuccin/nvim', as = 'catppuccin' }
  use 'folke/tokyonight.nvim'
  use 'EdenEast/nightfox.nvim'
  use 'ofirgall/ofirkai.nvim'
  use 'nyoom-engineering/oxocarbon.nvim'

  use {
    'kyazdani42/nvim-tree.lua',
    requires = { 'kyazdani42/nvim-web-devicons' },
  }

  use { 'numToStr/Comment.nvim' }

  use {
    'folke/trouble.nvim',
    requires = 'kyazdani42/nvim-web-devicons',
  }

  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true },
  }

  use 'tpope/vim-fugitive'
  use 'lewis6991/gitsigns.nvim'
  use { 'sindrets/diffview.nvim', requires = 'nvim-lua/plenary.nvim' }

  use {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.0',
    requires = { { 'nvim-lua/plenary.nvim' } },
  }
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }

  use 'lukas-reineke/indent-blankline.nvim'

  use {
    'windwp/nvim-autopairs',
    config = function()
      require('nvim-autopairs').setup {}
    end,
  }

  use {
    'akinsho/bufferline.nvim',
    tag = 'v3.*',
    requires = 'nvim-tree/nvim-web-devicons',
  }

  -- use fork of karb94/neoscroll.nvim until time-scale branch is merged to main
  -- use 'karb94/neoscroll.nvim'
  use {
    'bvaughnsulit/neoscroll.nvim',
    branch = 'time-scale',
  }

  use { 'Wansmer/treesj', requires = { 'nvim-treesitter' } }

  use 'numToStr/Navigator.nvim'
end)
