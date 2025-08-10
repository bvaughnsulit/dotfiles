local utils = require("config.utils")
local augroup = utils.augroup

vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function() vim.highlight.on_yank({ timeout = 500, higroup = "visual" }) end,
    group = augroup("hl_on_yank"),
    desc = "hl on yank",
})

vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
        vim.opt.formatoptions:remove("c") -- autowrap comments
        vim.opt.formatoptions:prepend("r") -- continue comment on enter
        vim.opt.formatoptions:prepend("o") -- continue comment on o/O
        vim.opt.formatoptions:prepend("/") -- only continue full line comments
    end,
    group = augroup("format_options"),
    desc = "prevent comments when creating newline before or after comment",
})

vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function() vim.cmd([[hi! default link MiniCursorword LspReferenceText]]) end,
    desc = "overwrite mini cursorword highlight group",
})

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
    group = augroup("wrap_spell"),
    pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.spell = true
        vim.opt_local.conceallevel = 3
    end,
})

vim.api.nvim_create_autocmd("TermOpen", {
    group = augroup("term_open"),
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.wrap = true
    end,
    desc = "Configure terminal buffer",
})

vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = augroup("checktime"),
    callback = function()
        if vim.o.buftype ~= "nofile" then vim.cmd("checktime") end
    end,
})

-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup("last_loc"),
    callback = function(event)
        local exclude = { "gitcommit" }
        local buf = event.buf
        if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].last_loc then return end
        vim.b[buf].last_loc = true
        local mark = vim.api.nvim_buf_get_mark(buf, '"')
        local lcount = vim.api.nvim_buf_line_count(buf)
        if mark[1] > 0 and mark[1] <= lcount then pcall(vim.api.nvim_win_set_cursor, 0, mark) end
    end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
    group = augroup("close_with_q"),
    pattern = {
        "checkhealth",
        "dbout",
        "gitsigns-blame",
        "grug-far",
        "help",
        "lspinfo",
        "neotest-output",
        "neotest-output-panel",
        "neotest-summary",
        "notify",
        "qf",
        "snacks_win",
        "spectre_panel",
        "startuptime",
        "tsplayground",
    },
    callback = function(event)
        vim.schedule(function()
            vim.keymap.set("n", "q", function() vim.cmd("close") end, {
                buffer = event.buf,
                silent = true,
                desc = "Quit buffer",
            })
        end)
    end,
})

-- Fix conceallevel for json files
vim.api.nvim_create_autocmd({ "FileType" }, {
    group = augroup("json_conceal"),
    pattern = { "json", "jsonc", "json5" },
    callback = function() vim.opt_local.conceallevel = 0 end,
})

vim.api.nvim_create_autocmd("CmdwinEnter", {
    group = augroup("cmdwin_enter"),
    callback = function(event)
        vim.wo.foldenable = false
        vim.schedule(function()
            vim.keymap.set("n", "q", function() vim.cmd("close") end, {
                buffer = event.buf,
                silent = true,
                desc = "Quit buffer",
            })
        end)
    end,
    desc = "",
})
