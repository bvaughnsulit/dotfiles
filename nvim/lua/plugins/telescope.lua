local utils = require('config.utils')
local pickers = require('config.pickers')

return {
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'debugloop/telescope-undo.nvim',
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-live-grep-args.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        config = function() require('telescope').load_extension('fzf') end,
      },
    },
    config = function()
      local telescope = require('telescope')
      local actions = require('telescope.actions')
      local builtin = require('telescope.builtin')
      local previewers = require('telescope.previewers')

      telescope.load_extension('undo')
      telescope.load_extension('live_grep_args')
      telescope.load_extension('aerial')
      local telescope_dropdown = require('telescope.themes').get_dropdown

      telescope.setup({
        pickers = {
          buffers = {
            theme = 'dropdown',
            ignore_current_buffer = true,
            sort_mru = true,
            mappings = {
              i = {
                ['<C-x>'] = 'delete_buffer',
              },
            },
          },
          help_tags = {
            mappings = {
              i = {
                ['<CR>'] = 'select_vertical',
              },
            },
          },
          commands = {
            mappings = {
              i = {
                ['<leader><leader>'] = actions.close,
              },
            },
          },
          lsp_references = {
            include_declaration = false,
            fname_width = 60,
            show_line = false,
            trim_text = true,
          },
          lsp_definitions = {
            fname_width = 60,
            show_line = false,
            trim_text = true,
          },
        },
        defaults = {
          layout_strategy = 'vertical',
          color_devicons = true,
          dynamic_preview_title = true,
          layout_config = {
            anchor = 'N',
            mirror = true,
            prompt_position = 'top',
            width = 0.9,
            height = 0.95,
            preview_cutoff = 0,
          },
          file_ignore_patterns = {
            'package%-lock%.json',
            'static/',
            'public/',
            -- '%node_modules%',
            '%.git/',
            '%.png$',
            '%.svg$',
            '%.gif$',
            '%.jpg$',
            '%.jpeg$',
          },
          mappings = {
            i = {
              ['<esc>'] = actions.close,
              ['<c-q>'] = false,
              ['<c-q>a'] = actions.smart_add_to_qflist,
              ['<c-q>r'] = actions.smart_send_to_qflist,
              ['<m-up>'] = actions.cycle_history_prev,
              ['<m-down>'] = actions.cycle_history_next,
            },
          },
        },
        extensions = {
          file_browser = {
            theme = 'dropdown',
            -- hijack_netrw = true,
          },
          undo = {},
        },
      })

      -- show line numbers in preview window
      vim.api.nvim_create_autocmd('User', {
        pattern = 'TelescopePreviewerLoaded',
        group = vim.api.nvim_create_augroup('telescope_nums', { clear = true }),
        callback = function()
          vim.opt_local.number = true
          vim.opt.numberwidth = 5
        end,
      })

      vim.keymap.set(
        'n',
        '<C-p>',
        function()
          require('telescope.builtin').find_files(require('telescope.themes').get_dropdown({
            hidden = true,
            layout_config = {
              width = 0.9,
            },
          }))
        end,
        { desc = 'Find Files' }
      )

      vim.keymap.set(
        'n',
        '<C-b>',
        function()
          require('telescope.builtin').buffers(require('telescope.themes').get_dropdown({
            sort_mru = true,
            bufnr_width = 3,
            ignore_current_buffer = true,
            layout_config = {
              width = 0.9,
              anchor = 'N',
            },
            path_display = { 'filename_first' },
          }))
        end,
        { desc = 'Buffers' }
      )

      vim.keymap.set('n', '<C-f>', function() builtin.live_grep({}) end, {
        desc = 'Live Grep',
      })

      vim.keymap.set(
        'n',
        'gd',
        function()
          builtin.lsp_definitions(telescope_dropdown({
            layout_config = {
              anchor = 'N',
              width = 0.9,
            },
          }))
        end,
        {
          desc = 'Goto Definition',
          nowait = true,
        }
      )
      vim.keymap.set(
        'n',
        'gr',
        function()
          builtin.lsp_references(telescope_dropdown({
            layout_config = {
              anchor = 'N',
              width = 0.9,
            },
          }))
        end,
        {
          desc = 'Goto References',
          nowait = true,
        }
      )

      vim.keymap.set(
        'n',
        'gt',
        function()
          builtin.lsp_type_definitions(telescope_dropdown({
            layout_config = {
              anchor = 'N',
              width = 0.9,
            },
          }))
        end,
        {
          desc = 'Goto Type Definition',
          nowait = true,
        }
      )

      vim.keymap.set('n', '<leader>km', '<cmd>Telescope keymaps<cr>')
      vim.keymap.set('n', '<leader>?', '<cmd>Telescope help_tags<cr>')
      vim.keymap.set('n', '<leader><leader>', require('telescope.builtin').commands)
      vim.keymap.set(
        'n',
        '<leader>/f',
        function()
          require('telescope.builtin').current_buffer_fuzzy_find(
            require('telescope.themes').get_dropdown({
              layout_config = {
                width = 0.9,
              },
            })
          )
        end,
        { desc = '[/] Fuzzily search in current buffer]' }
      )

      -- other maps
      vim.keymap.set('n', '<leader><up>', function() builtin.resume() end, {
        desc = 'Resume Last',
      })

      vim.keymap.set(
        'n',
        '<leader>sbt',
        function()
          builtin.live_grep({
            glob_pattern = '**/tests/**/*.py',
          })
        end,
        { desc = 'Search Python Tests' }
      )

      vim.keymap.set(
        'n',
        '<leader>jj',
        function()
          require('telescope.builtin').jumplist(require('telescope.themes').get_dropdown({
            show_line = false,
            layout_config = {
              width = 0.8,
            },
          }))
        end,
        { desc = 'Jump List' }
      )

      local search_commits = function()
        builtin.git_commits({
          previewer = previewers.git_commit_diff_as_was.new({}),
        })
      end
      vim.api.nvim_create_user_command('TelescopeSearchCommits', search_commits, {})

      vim.keymap.set(
        'n',
        '<leader>vv',
        function()
          require('telescope.builtin').registers({
            initial_mode = 'normal',
          })
        end,
        { desc = 'View Registers' }
      )

      local branch = utils.get_default_branch_name()
      utils.create_cmd_and_map(
        'SearchGitDiffMain',
        '<leader>sg',
        function()
          require('telescope.builtin').git_files(require('telescope.themes').get_dropdown({
            git_command = { 'git', 'diff', branch, '--name-only' },
            layout_config = {
              width = 0.8,
            },
          }))
        end,
        'Search Git Status Files'
      )

      utils.create_cmd_and_map(
        'ViewTextObjectMappings',
        nil,
        function()
          require('telescope.builtin').keymaps(require('telescope.themes').get_dropdown({
            modes = { 'o' },
            layout_config = {
              width = 0.8,
              height = 0.9,
            },
          }))
        end,
        'View Operator Pending Maps'
      )

      vim.keymap.set(
        'n',
        '<leader>dt',
        function()
          require('telescope.builtin').diagnostics(require('telescope.themes').get_dropdown({
            initial_mode = 'normal',
            no_sign = false,
            layout_config = {
              anchor = 'S',
              mirror = 'false',
              width = 0.7,
            },
          }))
        end
      )

      -- browse themes
      vim.api.nvim_create_user_command(
        'ThemeBrowse',
        function()
          require('telescope.builtin').colorscheme({
            layout_config = {
              height = 0.5,
              preview = false,
              width = 0.2,
            },
            enable_preview = true,
          })
        end,
        {}
      )
      utils.create_cmd_and_map(
        'LiveGrepArgs',
        '<leader>sf',
        function() telescope.extensions.live_grep_args.live_grep_args() end,
        'Telescope Live Grep Args'
      )

      vim.api.nvim_create_user_command('T', 'Telescope', {})
    end,
  },
  {
    'nvim-telescope/telescope-file-browser.nvim',
    event = 'VeryLazy',
    config = function()
      local telescope = require('telescope')
      telescope.load_extension('file_browser')
      vim.keymap.set(
        'n',
        '<leader>eb',
        function()
          telescope.extensions.file_browser.file_browser({
            files = false,
            depth = false,
            auto_depth = true,
            hidden = false,
            respect_gitignore = true,
            collapse_dirs = true,
            use_fd = true,
            hide_parent_dir = true,
            grouped = true,
          })
        end
      )
    end,
  },
}
