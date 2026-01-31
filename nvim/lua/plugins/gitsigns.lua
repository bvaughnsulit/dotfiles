local utils = require("config.utils")
local git = require("config.git")

---@module 'lazy'
---@type LazySpec
return {
    "https://github.com/lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    opts = function()
        ---@type Gitsigns.Config
        ---@diagnostic disable: missing-fields
        local opts = {
            trouble = false,
            signs = {
                add = { text = "│" },
                change = { text = "│" },
                delete = { text = "_" },
                topdelete = { text = "‾" },
                changedelete = { text = "│" },
                untracked = { text = "┆" },
            },
            signs_staged = {
                add = { text = "▐" },
                change = { text = "▌" },
                delete = { text = "▄" },
                topdelete = { text = "▀" },
                changedelete = { text = "▌" },
                untracked = { text = "▌" },
            },
            base = git.get_git_base().hash,
            diff_opts = {
                internal = true,
            },
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
                local gitsigns = require("gitsigns")

                local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end

                map("n", "]c", function()
                    if vim.wo.diff then return "]c" end
                    vim.schedule(
                        function()
                            gitsigns.nav_hunk("next", {
                                wrap = false,
                                preview = true,
                                foldopen = true,
                                target = "all",
                            })
                        end
                    )
                    return "<Ignore>"
                end, { expr = true })

                map("n", "[c", function()
                    if vim.wo.diff then return "[c" end
                    vim.schedule(
                        function()
                            gitsigns.nav_hunk("prev", {
                                wrap = false,
                                preview = true,
                                foldopen = true,
                                target = "all",
                            })
                        end
                    )
                    return "<Ignore>"
                end, { expr = true })

                -- Actions
                map("n", "<leader>hh", function() gitsigns.preview_hunk() end)
                map("n", "<leader>gb", function() gitsigns.blame_line({ full = true }) end)
                map({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>")
                map({ "n", "v" }, "<leader>hr", function() gitsigns.reset_hunk() end)
                map(
                    { "n", "v" },
                    "<leader>gl",
                    function() gitsigns.setqflist("all") end,
                    { desc = "Send all hunks to quickfix list" }
                )
                -- map("n", "<leader>hu", gitsigns.undo_stage_hunk)
                -- map("n", "<leader>gx", gitsigns.toggle_deleted)
                -- map('n', '<leader>hS', gitsigns.stage_buffer)
                -- map('n', '<leader>hR', gitsigns.reset_buffer)
                -- map('n', '<leader>tb', gitsigns.toggle_current_line_blame)
                -- map('n', '<leader>hd', gitsigns.diffthis)
                -- map('n', '<leader>hD', function() gitsigns.diffthis('~') end)

                -- Text object
                -- map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
            end,
        }
        ---@diagnostic enable: missing-fields

        vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
            group = utils.augroup("gitsigns_refresh"),
            callback = function()
                if vim.o.buftype ~= "nofile" then require("gitsigns").change_base(git.get_git_base().hash, true) end
            end,
        })
        return opts
    end,
}
