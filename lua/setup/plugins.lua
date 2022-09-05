vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  


  use {'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }
  use { 'echasnovski/mini.nvim', branch = 'stable' }

  use {"folke/which-key.nvim"}

  --themes
  use 'marko-cerovac/material.nvim'
  use 'https://gitlab.com/__tpb/monokai-pro.nvim'
  use 'ishan9299/nvim-solarized-lua'
  use 'shaunsingh/solarized.nvim'
  
  use {'kyazdani42/nvim-tree.lua',
    requires = {'kyazdani42/nvim-web-devicons'}
  }

  use {
    'numToStr/Comment.nvim',
    config = function()
        require('Comment').setup()
    end
  }
 
  use {
    "folke/trouble.nvim",
    requires = "kyazdani42/nvim-web-devicons",
  }

  use {'nvim-lualine/lualine.nvim',
    requires = {
      'kyazdani42/nvim-web-devicons',
      opt = true
    }
  }
  
  use {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.0',
    requires = {
      {'nvim-lua/plenary.nvim'}
    }
  }

  use {
    "akinsho/toggleterm.nvim",
    tag = 'v2.*',
  }

  use "lukas-reineke/indent-blankline.nvim"

  -- LSP
  use 'neovim/nvim-lspconfig'
  use 'hrsh7th/nvim-cmp' -- Autocompletion plugin
  use 'hrsh7th/cmp-nvim-lsp' -- LSP source for nvim-cmp
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'L3MON4D3/LuaSnip'

end)


