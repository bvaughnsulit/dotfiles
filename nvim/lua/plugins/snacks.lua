local utils = require("config.utils")
local pickers = require("config.pickers")

--- @type string[]
local always_exclude = {
    "package-lock.json",
    "*.git/",
}

--- @type string[]
local enabled_toggles = { "tests", "data", "media" }

--- @type table<string, string[]>
local exclude_toggles = {
    tests = {
        "**/test_*.*",
        "*.test.*",
        "*_spec.*",
    },
    data = {
        "*.json",
        "*.jsonc",
        "*.md",
        "*.txt",
        "*.csv",
        "*.sql",
        "*.toml",
        "*.yml",
        "*.yaml",
        "**/migrations/**",
    },
    media = {
        "**/static/**",
        "**/public/**",
        "*.png",
        "*.svg",
        "*.gif",
        "*.jpg",
        "*.jpeg",
    },
}

--- @return string[]
local get_grep_excludes = function()
    ---@type string[]
    local config = require("config.settings").grep_exclude
    ---@type string[][]
    local toggled = vim.tbl_map(function(t) return exclude_toggles[t] or {} end, enabled_toggles)
    return vim.tbl_extend("force", always_exclude, config or {}, vim.fn.flatten(toggled))
end

--- @type fun(win: snacks.win)
local custom_close = function(win)
    if vim.fn.mode():sub(1, 1) == "n" or win:line() == "" then
        win.opts.actions.close.action(win)
    else
        vim.cmd.stopinsert()
    end
end

--- @param item snacks.picker.Item
local get_filename_from_item = function(item)
    local filename = item and item.file
    if not filename then return nil end

    if item.end_pos and item.end_pos[1] then
        filename = filename .. ":" .. item.end_pos[1]
        if item.end_pos[2] then filename = filename .. ":" .. item.end_pos[2] end
    end
    return filename
end

---@module 'lazy'
---@type LazySpec
return {
    "https://github.com/folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    init = function()
        _G.logger = function(...) Snacks.debug.inspect(...) end
    end,
    opts = function()
        ---@type snacks.Config
        return {
            lazygit = { enabled = false },
            words = { enabled = false },

            notifier = { enabled = true },
            quickfile = { enabled = true },
            bigfile = { enabled = true },
            input = { enabled = true },
            scope = { enabled = true },
            picker = {
                sources = {
                    treesitter = {
                        filter = { default = true },
                    },
                    lsp_symbols = {
                        filter = { default = true },
                    },
                    help = {
                        confirm = {
                            action = "help",
                            cmd = "vsplit",
                        },
                    },
                    files = {
                        hidden = true,
                    },
                    keymaps = {
                        plugs = true,
                    },
                },
                debug = {
                    -- grep = true,
                },
                main = {
                    -- focus last win on picker close
                    current = true,
                },
                layout = function(source)
                    return {
                        cycle = true,
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
                        auto_hide = source == "select" and { "preview" } or {},
                    }
                end,
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
                    debug_item = function(_, item) logger(item) end,
                    debug_picker = function(picker) logger(picker) end,
                    copy_filename_to_clipboard = function(_, item)
                        local filename = get_filename_from_item(item)
                        if not filename then return end
                        vim.fn.setreg("+", filename)
                        vim.notify("Copied to clipboard: " .. filename, vim.log.levels.INFO)
                    end,
                    put_filename = function(picker, item)
                        local filename = get_filename_from_item(item)
                        if not filename then return end
                        picker:close()
                        if vim.api.nvim_buf_get_name(0):find("term://ai_cli") then filename = "@" .. filename .. " " end
                        vim.api.nvim_put({ filename }, "c", true, true)
                    end,
                    select_filters = function(picker)
                        vim.ui.select(vim.tbl_keys(exclude_toggles), {
                            prompt = "Toggle exclude patterns",
                            format_item = function(item)
                                return (vim.tbl_contains(enabled_toggles, item) and " " or "  ") .. item
                            end,
                        }, function(selection)
                            if not selection then return end

                            logger(selection)
                            if vim.tbl_contains(enabled_toggles, selection) then
                                enabled_toggles = vim.tbl_filter(function(t) return t ~= selection end, enabled_toggles)
                            else
                                table.insert(enabled_toggles, selection)
                            end

                            ---@diagnostic disable-next-line: inject-field
                            picker.opts.exclude = get_grep_excludes()
                            picker.title = "grep (excludes: " .. table.concat(enabled_toggles, ", ") .. ")"

                            picker:update_titles()
                            picker.list:set_target()
                            picker:find()
                        end)
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
                            ["<c-f>"] = { "select_filters", mode = { "i", "n" } },
                            ["<c-_>"] = { "toggle_help_input", mode = { "i", "n" } },
                            ["<c-y>"] = { "copy_filename_to_clipboard", mode = { "i", "n" } },
                            ["<c-s>"] = { "put_filename", mode = { "i", "n" } },
                            ["<leader>,i"] = { "debug_item", mode = { "n" } },
                            ["<leader>,p"] = { "debug_picker", mode = { "n" } },
                            ["<Down>"] = { "history_forward", mode = { "i", "n" } },
                            ["<Up>"] = { "history_back", mode = { "i", "n" } },
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
            "<leader>pG",
            function() Snacks.picker.git_log() end,
            desc = "Pick Git log",
        },
        {
            "<leader>pb",
            function() Snacks.picker.git_branches() end,
            desc = "Pick Git branch",
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

        -- TODO: qf append
        pickers.register_picker("snacks", {
            buffers = function()
                Snacks.picker.buffers({
                    preview = function(ctx)
                        -- prevents using the actual buffer in the previewer to preserve lastused values
                        ctx.item.buf = nil
                        if ctx.item.buftype == "terminal" then
                            ctx.preview:set_lines({ ctx.item.file })
                            return
                        end
                        return Snacks.picker.preview.file(ctx)
                    end,
                    current = false,
                })
            end,

            live_grep = function()
                Snacks.picker.grep({
                    hidden = true,
                    ignored = false,
                    cwd = Snacks.git.get_root(),
                    exclude = get_grep_excludes(),
                    title = "grep (excluding: " .. table.concat(enabled_toggles, ", ") .. ")",
                })
            end,

            live_grep_no_filters = function()
                Snacks.picker.grep({
                    hidden = true,
                    ignored = false,
                    cwd = Snacks.git.get_root(),
                    -- exclude= get_grep_excludes(),
                    title = "Live grep (no filters)",
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

            find_files = function() Snacks.picker.files() end,
            keymaps = function() Snacks.picker.keymaps() end,

            help_tags = function() Snacks.picker.help() end,
            lsp_definitions = function() Snacks.picker.lsp_definitions() end,
            lsp_references = function() Snacks.picker.lsp_references() end,
            lsp_type_definitions = function() Snacks.picker.lsp_type_definitions() end,
            buffer_fuzzy = function() Snacks.picker.lines() end,
            resume = function() Snacks.picker.resume() end,
            pickers = function() Snacks.picker.pickers() end,
        })
    end,
}
