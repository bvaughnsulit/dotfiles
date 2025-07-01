local utils = require("config.utils")
local pickers = require("config.pickers")

local default_excludes = {
    "package-lock.json",
    "**/static/**",
    "**/public/**",
    -- '%node_modules%',
    "*.git/",
    "*.png",
    "*.svg",
    "*.gif",
    "*.jpg",
    "*.jpeg",
    "*.csv",
}

--- @type fun(win: snacks.win)
local custom_close = function(win)
    if vim.fn.mode():sub(1, 1) == "n" or win:line() == "" then
        win.opts.actions.close.action(win)
    else
        vim.cmd.stopinsert()
    end
end

return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    init = function()
        _G.logger = function(...) Snacks.debug.inspect(...) end
    end,
    opts = function()
        ---@type snacks.Config
        return {
            lazygit = { enabled = false },
            notifier = { enabled = true },
            quickfile = { enabled = true },
            bigfile = { enabled = true },
            words = { enabled = true },
            input = { enabled = true },
            statuscolumn = { enabled = false },
            scope = { enabled = true },
            picker = {
                layout = {
                    layout = {
                        backdrop = false,
                        row = 1,
                        width = 0.95,
                        min_width = 80,
                        height = 0.95,
                        border = "none",
                        box = "vertical",
                        {
                            box = "vertical",
                            border = "rounded",
                            title = "{title}",
                            title_pos = "center",
                            { win = "input", height = 1, border = "bottom" },
                            { win = "list", border = "none" },
                        },
                        { win = "preview", title = "{preview}", height = 0.7, border = "rounded" },
                    },
                },
                formatters = {
                    file = {
                        filename_first = true,
                        truncate = 100,
                    },
                },
                previewers = {
                    diff = {
                        builtin = false,
                        cmd = { "delta" },
                    },
                    git = {
                        builtin = false,
                    },
                },
                win = {
                    input = {
                        keys = {
                            ---@diagnostic disable-next-line: assign-type-mismatch
                            ["<Esc>"] = { custom_close, mode = { "n", "i" } },
                            ---@diagnostic disable-next-line: assign-type-mismatch
                            ["<c-c>"] = { custom_close, mode = { "n", "i" } },
                            ["<c-u>"] = { "preview_scroll_up", mode = { "i", "n" } },
                            ["<c-d>"] = { "preview_scroll_down", mode = { "i", "n" } },
                            ["<c-_>"] = { "toggle_help_input", mode = { "i", "n" } },
                        },
                    },
                },
            },
            styles = {
                lazygit = {
                    width = 0,
                    height = 0,
                    relative = "editor",
                    keys = {
                        term_normal = false,
                        t_q = {
                            "q",
                            function() Snacks.lazygit.open() end,
                            mode = "t",
                            expr = true,
                        },
                    },
                },
            },
        }
    end,
    keys = {
        {
            "<leader>ps",
            function() Snacks.picker.lazy() end,
            desc = "Plugin specs",
        },
        {
            "<leader>pg",
            function() Snacks.picker.git_status() end,
            desc = "Pick Git status",
        },
        {
            "<leader>pb",
            function() Snacks.picker.git_branches() end,
            desc = "Pick Git branch",
        },
        {
            "<leader>\\\\",
            function() Snacks.terminal.toggle() end,
        },
    },
    config = function(_, opts)
        require("snacks").setup(opts)

        local grep_nvim_plugins_source = function()
            Snacks.picker.grep(
                --- @type snacks.picker.grep.Config
                {
                    hidden = true,
                    cwd = "~/.local/share/nvim/lazy",
                }
            )
        end
        utils.create_cmd_and_map("GrepNvimPlugins", nil, grep_nvim_plugins_source, "")

        pickers.register_picker("snacks", {
            find_files = function()
                Snacks.picker.files(
                    ---@type snacks.picker.files.Config
                    {
                        hidden = true,
                    }
                )
            end,

            -- buffers = function()
            --     Snacks.picker.buffers(
            --         --- @type snacks.picker.buffers.Config
            --         {
            --             current = false,
            --             -- sort = { fields = {} },
            --         }
            --     )
            -- end,

            live_grep = function()
                Snacks.picker.grep(
                    --- @type snacks.picker.grep.Config
                    {
                        hidden = true,
                        ignored = false,
                        cwd = Snacks.git.get_root(),
                        exclude = default_excludes,
                    }
                )
            end,

            lsp_definitions = function() Snacks.picker.lsp_definitions() end,

            lsp_references = function() Snacks.picker.lsp_references() end,

            lsp_type_definitions = function() Snacks.picker.lsp_type_definitions() end,

            buffer_fuzzy = function() Snacks.picker.lines() end,

            keymaps = function() Snacks.picker.keymaps() end,

            help_tags = function() Snacks.picker.help() end,

            commands = function()
                Snacks.picker.commands({
                    confirm = function(picker, item)
                        picker:close()
                        if item and item.cmd then vim.schedule(function() vim.cmd(item.cmd) end) end
                    end,
                })
            end,

            pickers = function() Snacks.picker.pickers() end,

            resume = function() Snacks.picker.resume() end,
        })
    end,
}
