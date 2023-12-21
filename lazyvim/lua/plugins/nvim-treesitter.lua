return {
  {
    'nvim-treesitter/playground',
    cmd = 'TSPlaygroundToggle',
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    opts = {
      max_lines = 0,
      min_window_height = 40,
    },
  },
  {
    'nvim-treesitter/nvim-treesitter',
    keys = {
      { '<c-space>', false },
      { '<bs>', false },
    },
    opts = {
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = 'gnn',
          node_incremental = '<c-n>',
          scope_incremental = 'grc',
          node_decremental = '<c-m>',
        },
      },
      textobjects = {
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            [']a'] = '@parameter.inner',
            [']m'] = '@function.outer',
            [']]'] = '@block.outer',
            [']c'] = nil,
          },
          goto_next_end = {
            [']M'] = '@function.outer',
            [']['] = '@block.outer',
          },
          goto_previous_start = {
            ['[a'] = '@parameter.inner',
            ['[m'] = '@function.outer',
            ['[['] = '@block.outer',
            [']c'] = nil,
          },
          goto_previous_end = {
            ['[M'] = '@function.outer',
            ['[]'] = '@block.outer',
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ['<leader>a'] = '@parameter.inner',
          },
          swap_previous = {
            ['<leader>A'] = '@parameter.inner',
          },
        },
        lsp_interop = {
          enable = true,
          border = 'none',
          peek_definition_code = {
            ['<leader>df'] = '@function.outer',
            ['<leader>dF'] = '@class.outer',
          },
        },
      },
    },
  },
  {
    'stevearc/aerial.nvim',
    event = 'VeryLazy',
    config = function()
      require('aerial').setup({
        layout = {
          width = 0.35,
          max_width = 0.5,
        },
        highlight_on_hover = true,
        highlight_on_jump = 300,
        autojump = true,
      })
    end,
  },
}
