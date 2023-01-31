return {
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  {
    'nvim-telescope/telescope.nvim',
    version = '0.1.0',
    dependencies = { { 'nvim-lua/plenary.nvim' } },
    config = function()
      local actions = require 'telescope.actions'
      local builtin = require 'telescope.builtin'
      local previewers = require 'telescope.previewers'

      require('telescope').setup {
        defaults = {
          layout_strategy = 'vertical',
          path_display = {
            -- shorten = {
            --   exclude = {1, -1}
            -- }
          },
          color_devicons = true,
          layout_config = {
            mirror = true,
            prompt_position = 'top',
            width = 0.8,
            height = 0.95,
            preview_cutoff = 0,
          },
          pickers = {
            find_files = { -- why doesn't this work??
              hidden = true,
            },
            buffers = {
              theme = 'dropdown',
              ignore_current_buffer = true,
              sort_mru = true,
            },
          },
          file_ignore_patterns = {
            'package%-lock%.json',
            '^.git/',
            '%.png$',
            '%.svg$',
            '%.gif$',
            '%.jpg$',
            '%.jpeg$',
          },
          mappings = {
            i = {
              ['<esc>'] = actions.close,
              -- ["<C-u>"] = false,
            },
          },
        },
      }

      require('telescope').load_extension 'fzf'

      local search_commits = function()
        builtin.git_commits {
          previewer = previewers.git_commit_diff_as_was.new {},
        }
      end

      vim.api.nvim_create_user_command('TelescopeSearchCommits', search_commits, {})

      vim.keymap.set('n', '<leader>vv', function()
        require('telescope.builtin').registers { initial_mode = 'normal' }
      end, {})

      vim.keymap.set('n', '<C-p>', [[<cmd>lua require('telescope.builtin').find_files({hidden=true})<cr>]])

      vim.keymap.set('n', '<C-f>', [[<cmd>lua require('telescope.builtin').live_grep()<cr>]])

      vim.keymap.set('n', '<C-b>', function()
        require('telescope.builtin').buffers(require('telescope.themes').get_dropdown {
          sort_mru = true,
          bufnr_width = 3,
          ignore_current_buffer = true,
          initial_mode = 'normal',
          layout_config = { anchor = 'N' },
          path_display = function(_, path)
            local maxWidth = 60
            local maxTailLen = 26
            local spaceLen = 4

            local tail = require('telescope.utils').path_tail(path)
            local tailLen = string.len(tail)
            local relative_path = string.sub(path, 1, -tailLen - 1)
            if tailLen > maxTailLen then
              tail = string.sub(tail, 1, maxTailLen - 3) .. '...'
              tailLen = string.len(tail)
            end
            local spacing = string.rep(' ', (maxTailLen + spaceLen) - tailLen)

            local pathLen = string.len(relative_path)
            local maxPathLen = maxWidth - maxTailLen - spaceLen
            if pathLen == 0 then
              relative_path = '/'
            end
            if pathLen > maxPathLen then
              local minStartIndex = pathLen - maxPathLen + 3
              local startIndex = string.find(relative_path, '/', minStartIndex)
              if startIndex >= pathLen then
                startIndex = minStartIndex
              end
              relative_path = '...' .. string.sub(relative_path, startIndex)
            end
            return tail .. spacing .. relative_path
          end,
        })
      end)

      vim.keymap.set('n', '<leader>/f', function()
        require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          layout_config = {
            anchor = 'S',
            width = 0.7,
          },
        })
      end, { desc = '[/] Fuzzily search in current buffer]' })

      vim.keymap.set('n', '<leader>km', '<cmd>Telescope keymaps<cr>')

      vim.keymap.set('n', '<leader>?', '<cmd>Telescope help_tags<cr>')

      vim.keymap.set('n', '<leader>do', function()
        require('telescope.builtin').diagnostics(require('telescope.themes').get_dropdown {
          initial_mode = 'normal',
          no_sign = false,
          layout_config = {
            anchor = 'S',
            mirror = 'false',
            width = 0.7,
          },
        })
      end)
    end,
  },
}
