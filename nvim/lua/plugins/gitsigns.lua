local utils = require("config.utils")

return {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    config = function()
        require("gitsigns").setup({
            signs = {
                add = { text = "│" },
                change = { text = "│" },
                delete = { text = "_" },
                topdelete = { text = "‾" },
                changedelete = { text = "│" },
            },
            base = utils.get_merge_base_hash(),
            signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
            numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
            linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
            word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
            watch_gitdir = {
                interval = 1000,
                follow_files = true,
            },
            diff_opts = {
                internal = true,
                vertical = true,
            },
            attach_to_untracked = true,
            current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
            current_line_blame_opts = {
                virt_text = true,
                virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
                delay = 1000,
                ignore_whitespace = false,
            },
            current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
            sign_priority = 6,
            update_debounce = 100,
            status_formatter = nil, -- Use default
            max_file_length = 40000, -- Disable if file is longer than this (in lines)
            preview_config = {
                -- Options passed to nvim_open_win
                border = "single",
                style = "minimal",
                relative = "cursor",
                row = 0,
                col = 0,
                anchor = "SW",
            },
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns

                local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end

                -- Navigation
                map("n", "]c", function()
                    if vim.wo.diff then return "]c" end
                    vim.schedule(
                        function()
                            gs.next_hunk({
                                wrap = false,
                                preview = true,
                            })
                        end
                    )
                    return "<Ignore>"
                end, { expr = true })

                map("n", "[c", function()
                    if vim.wo.diff then return "[c" end
                    vim.schedule(
                        function()
                            gs.prev_hunk({
                                wrap = false,
                                preview = true,
                            })
                        end
                    )
                    return "<Ignore>"
                end, { expr = true })

                -- Actions
                map({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>")
                map({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>")
                -- map('n', '<leader>hS', gs.stage_buffer)
                map("n", "<leader>hu", gs.undo_stage_hunk)
                -- map('n', '<leader>hR', gs.reset_buffer)
                map("n", "<leader>gh", gs.preview_hunk)
                map("n", "<leader>gb", function() gs.blame_line({ full = true }) end)
                -- map('n', '<leader>tb', gs.toggle_current_line_blame)
                -- map('n', '<leader>hd', gs.diffthis)
                -- map('n', '<leader>hD', function() gs.diffthis('~') end)
                map("n", "<leader>gx", gs.toggle_deleted)

                -- Text object
                -- map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
            end,
        })

        vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
            group = utils.augroup("gitsigns_refresh"),
            callback = function()
                if vim.o.buftype ~= "nofile" then require("gitsigns").refresh() end
            end,
        })
    end,
}
