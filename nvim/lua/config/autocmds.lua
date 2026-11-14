local utils = require("config.utils")
local augroup = utils.augroup

vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "hl on yank",
    callback = function() vim.highlight.on_yank({ timeout = 500, higroup = "visual" }) end,
    group = augroup("hl_on_yank"),
})

vim.api.nvim_create_autocmd("BufEnter", {
    desc = "prevent comments when creating newline before or after comment",
    callback = function()
        vim.opt.formatoptions:remove("c") -- autowrap comments
        vim.opt.formatoptions:prepend("r") -- continue comment on enter
        vim.opt.formatoptions:prepend("o") -- continue comment on o/O
        vim.opt.formatoptions:prepend("/") -- only continue full line comments
    end,
    group = augroup("format_options"),
})

vim.api.nvim_create_autocmd("ColorScheme", {
    desc = "overwrite mini cursorword highlight group",
    pattern = "*",
    callback = function() vim.cmd([[hi! default link MiniCursorword LspReferenceText]]) end,
})

local function set_gitsigns_unified_highlights()
    -- gitsigns unified diffthis fills the gutter of deleted lines with base line numbers;
    -- blend them into the background so the gutter looks empty
    local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
    vim.api.nvim_set_hl(0, "GitSignsVirtLnum", { fg = normal.bg, bg = normal.bg })
    -- drop the added-line background so CursorLine shows through; an empty group would be
    -- re-linked to DiffAdd by gitsigns, so set a cterm-only color (ignored with termguicolors)
    vim.api.nvim_set_hl(0, "GitSignsAddPreview", { ctermbg = 22 })
end
set_gitsigns_unified_highlights()
vim.api.nvim_create_autocmd("ColorScheme", {
    desc = "adjust gitsigns unified diffthis highlights",
    group = augroup("gitsigns_unified_highlights"),
    callback = set_gitsigns_unified_highlights,
})

vim.api.nvim_create_autocmd("FileType", {
    group = augroup("wrap_spell"),
    pattern = { "text", "plaintex", "gitcommit", "markdown" },
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.spell = false
        -- no "f" flag so <CR>/o/O repeat the list marker instead of aligning to the text
        vim.opt_local.comments = "b:- [ ],b:- [x],b:*,b:-,b:+,n:>"
    end,
})

vim.api.nvim_create_autocmd("TermOpen", {
    desc = "Configure terminal buffer",
    group = augroup("term_open"),
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.wrap = true
    end,
})

vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
    group = augroup("checktime"),
    callback = function()
        if vim.o.buftype ~= "nofile" then vim.cmd("checktime") end
    end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
    desc = "Go to last location when opening a buffer",
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

vim.api.nvim_create_autocmd("FileType", {
    desc = "Close buffers with 'q' in specific filetypes",
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

vim.api.nvim_create_autocmd({ "FileType" }, {
    desc = "Set conceallevel to 0 for JSON files",
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
    desc = "Close cmdwin with 'q'",
})
