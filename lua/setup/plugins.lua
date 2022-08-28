vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use {'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }


  --themes
  use 'marko-cerovac/material.nvim'
  use 'https://gitlab.com/__tpb/monokai-pro.nvim'

  use {'kyazdani42/nvim-tree.lua',
    requires = {'kyazdani42/nvim-web-devicons'}
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
  
  -- LSP
  use 'neovim/nvim-lspconfig'
  use 'hrsh7th/nvim-cmp' -- Autocompletion plugin
  use 'hrsh7th/cmp-nvim-lsp' -- LSP source for nvim-cmp
  use 'L3MON4D3/LuaSnip'

end)


