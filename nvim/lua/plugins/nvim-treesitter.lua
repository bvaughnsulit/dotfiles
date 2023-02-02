return {
  {
    'nvim-treesitter/playground',
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
  },
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup {
        -- A list of parser names, or "all"
        ensure_installed = 'all',
        context_commentstring = {
          enable = true,
          enable_autocmd = false,
        },
        -- Install parsers synchronously (only applied to `ensure_installed`)
        sync_install = false,

        -- Automatically install missing parsers when entering buffer
        auto_install = true,

        -- List of parsers to ignore installing (for "all")
        ignore_install = {
          'ada',
          'Glimmer and Ember',
          'Godot',
          'Godot Resources',
          'agda',
          'beancount',
          'bibtex',
          'c_sharp',
          'clojure',
          'cmake',
          'commonlisp',
          'cooklang',
          'cuda',
          'd',
          'dart',
          'devicetree',
          'dot',
          'eex',
          'elixir',
          'elm',
          'elvish',
          'embedded_template',
          'erlang',
          'fennel',
          'fish',
          'foam',
          'fortran',
          'fusion',
          'gleam',
          'glsl',
          'hack',
          'haskell',
          'hcl',
          'heex',
          'hjson',
          'hlsl',
          'hocon',
          'julia',
          'kotlin',
          'lalrpop',
          'latex',
          'ledger',
          'llvm',
          'm68k',
          'meson',
          'ninja',
          'nix',
          'norg',
          'ocaml',
          'ocaml_interface',
          'ocamllex',
          'org',
          'pascal',
          'perl',
          'pioasm',
          'proto',
          'pug',
          'ql',
          'qmljs',
          'r',
          'racket',
          'rasi',
          'rego',
          'rnoweb',
          'rst',
          'ruby',
          'scala',
          'scheme',
          'slint',
          'solidity',
          'sparql',
          'supercollider',
          'surface',
          'sxhkdrc',
          'teal',
          'tiger',
          'tlaplus',
          'toml',
          'turtle',
          'v',
          'vala',
          'verilog',
          'wgsl',
          'yang',
          'zig',
          'java',
          'jsonnet',
          'hjson',
          'jsonc',
        },

        highlight = {
          -- `false` will disable the whole extension
          enable = true,

          -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
          -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
          -- Using this option may slow down your editor, and you may see some duplicate highlights.
          -- Instead of true it can also be a list of languages
          additional_vim_regex_highlighting = false,
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = 'gnn',
            node_incremental = '<c-n>',
            scope_incremental = 'grc',
            node_decremental = '<c-m>',
          },
        },
        indent = {
          enable = true,
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['is'] = '@block.inner',
              ['as'] = '@block.outer',
              ['ic'] = '@call.inner',
              ['ac'] = '@call.outer',
              ['ia'] = '@parameter.inner',
              ['aa'] = '@parameter.outer',
              ['aC'] = '@class.outer',
              ['iC'] = '@class.inner',
            },
          },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
              [']a'] = '@parameter.inner',
              [']m'] = '@function.outer',
              [']]'] = '@block.outer',
            },
            goto_next_end = {
              [']M'] = '@function.outer',
              [']['] = '@block.outer',
            },
            goto_previous_start = {
              ['[a'] = '@parameter.inner',
              ['[m'] = '@function.outer',
              ['[['] = '@block.outer',
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
      }
    end,
  },
}
