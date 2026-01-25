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

local get_filename_from_item = function(item)
    local filename = item and item.file
    if not filename then return nil end

    if item.end_pos and item.end_pos[1] then
        filename = filename .. ":" .. item.end_pos[1]
        if item.end_pos[2] then filename = filename .. ":" .. item.end_pos[2] end
    end
    return filename
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
            words = { enabled = false },
            input = { enabled = true },
            scope = { enabled = true },
            picker = {
                layout = {
                    layout = {
                        backdrop = false,
                        row = 1,
                        width = 0.95,
                        min_width = 80,
                        height = 0.95,
                        box = "vertical",
                        border = "rounded",
                        title = "{title}",
                        title_pos = "center",
                        { win = "input", height = 1, border = "bottom" },
                        { win = "list", border = "none" },
                        { win = "preview", title = "{preview}", height = 0.7, border = "top" },
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
                actions = {
                    debug_item = function(_picker, item) logger(item) end,
                    debug_picker = function(picker) logger(picker) end,
                    copy_filename_to_clipboard = function(_picker, item)
                        local filename = get_filename_from_item(item)
                        if not filename then return end
                        vim.fn.setreg("+", filename)
                        vim.notify("Copied to clipboard: " .. filename, vim.log.levels.INFO)
                    end,
                    send_filename_to_sidekick = function(_picker, item)
                        local filename = get_filename_from_item(item)
                        if not filename then return end
                        require("sidekick.cli").send({
                            msg = "@" .. filename,
                            name = "claude",
                        })
                    end,
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
                            ["<c-y>"] = { "copy_filename_to_clipboard", mode = { "i", "n" } },
                            ["<c-s>"] = { "send_filename_to_sidekick", mode = { "i", "n" } },
                            ["<leader>,i"] = { "debug_item", mode = { "n" } },
                            ["<leader>,p"] = { "debug_picker", mode = { "n" } },
                        },
                    },
                },
            },
            styles = {},
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
            function() Snacks.picker.git_diff({ base = require("config.git").get_git_base().hash }) end,
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
                local default_exclude = {
                    "package-lock.json",
                    "*.git/",
                    "*.png",
                    "*.svg",
                    "*.gif",
                    "*.jpg",
                    "*.jpeg",
                }
                local grep_exclude =
                    vim.tbl_extend("force", default_exclude, require("config.settings").grep_exclude or {})

                Snacks.picker.grep(
                    --- @type snacks.picker.grep.Config
                    {
                        hidden = true,
                        ignored = false,
                        cwd = Snacks.git.get_root(),
                        exclude = grep_exclude,
                    }
                )
            end,

            lsp_definitions = function() Snacks.picker.lsp_definitions() end,

            lsp_references = function() Snacks.picker.lsp_references() end,

            lsp_type_definitions = function() Snacks.picker.lsp_type_definitions() end,

            buffer_fuzzy = function() Snacks.picker.lines() end,

            keymaps = function() Snacks.picker.keymaps({ plugs = true }) end,

            help_tags = function()
                Snacks.picker.help({
                    confirm = "vsplit",
                })
            end,

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
