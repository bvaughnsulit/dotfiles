require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all"
  ensure_installed = "all",

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  auto_install = true,

  -- List of parsers to ignore installing (for "all")
  ignore_install = { "Glimmer and Ember", "Godot", "Godot Resources", "agda", "beancount", "bibtex", "c_sharp", "clojure", "cmake", "commonlisp", "cooklang", "cuda", "d", "dart", "devicetree", "dot", "eex", "elixir", "elm", "elvish", "embedded_template", "erlang", "fennel", "fish", "foam", "fortran", "fusion", "gleam", "glsl", "hack", "haskell", "hcl", "heex", "hjson", "hlsl", "hocon", "julia", "kotlin", "lalrpop", "latex", "ledger", "llvm", "m68k", "meson", "ninja", "nix", "norg", "ocaml", "ocaml_interface", "ocamllex", "org", "pascal", "perl", "pioasm", "proto", "pug", "ql", "qmljs", "r", "racket", "rasi", "rego", "rnoweb", "rst", "ruby", "scala", "scheme", "slint", "solidity", "sparql", "supercollider", "surface", "sxhkdrc", "teal", "tiger", "tlaplus", "toml", "turtle", "v", "vala", "verilog", "wgsl", "yang", "zig", "java" },

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
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },
  indent = {
    enable = true
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
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
        ["<leader>df"] = "@function.outer",
        ["<leader>dF"] = "@class.outer",
      },
    },
  },
}
