vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
  use {'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }
  use 'marko-cerovac/material.nvim'
  use {'kyazdani42/nvim-tree.lua',
    requires = {'kyazdani42/nvim-web-devicons'}
  }
  use {'nvim-lualine/lualine.nvim',
    requires = {
      'kyazdani42/nvim-web-devicons',
      opt = true
    }
  }
 -- use {'neoclide/coc.nvim', branch = 'release'}
  use {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.0',
    requires = {
      {'nvim-lua/plenary.nvim'}
    }
  }
  use 'neovim/nvim-lspconfig'
end)


