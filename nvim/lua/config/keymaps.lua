local utils = require("config.utils")

local map = function(mode, lhs, rhs, opts)
    opts = vim.tbl_deep_extend("force", { remap = false, silent = true }, opts or {})
    vim.keymap.set(mode, lhs, rhs, opts)
end

map({ "n", "v" }, "<leader>bd", "<cmd>bdelete<cr>", {})

-- \V - very nomagic
map("n", "<leader>/y", "/\\V<C-r>+<cr>", { desc = "search with contents of + register" })
map("n", "<leader>*", "*N", { desc = "search word under cursor" })

map("n", "<leader>:", ":lua print(vim.inspect())<left><left>")
map({ "n", "v" }, "zf", "za", { desc = "Toggle fold" })
map({ "n" }, "zF", "zA", { desc = "Toggle fold recursively" })

map("n", "<cr>", function()
    if vim.wo.foldenable then
        return "za"
    else
        return "<cr>"
    end
end, { expr = true, silent = true, desc = "Toggle fold" })
map("n", "<a-cr>", "zA", { desc = "Toggle fold recursively" })

map({ "n", "v" }, "za", "zf", { desc = "Create fold" })
map({ "n", "v" }, "zA", "zF", { desc = "Create fold" })

map("n", "<leader>ra", ":%s/\\V<C-r>///gI<left><left><left>")
map("v", "<leader>ra", ":s/\\V<C-r>///gI<left><left><left>", { desc = "replace with last search in selected area" })

map("v", "<leader>lp", ":s/^//|noh<left><left><left><left><left>", { desc = "append selected lines" })
map("v", "<leader>la", ":s/$//|noh<left><left><left><left><left>", { desc = "prepend selected lines" })

-- always yank to system clipboard
map("n", "Y", '"+y$')
map({ "n", "v" }, "y", '"+y', {})

-- delete, change, put to black hole register
map({ "n", "v" }, "<leader>xd", '"_d', {})
map({ "n", "v" }, "<leader>xc", '"_c', {})
-- map({ "x" }, "<leader>p", "p", { desc = "hello" })
map({ "x" }, "p", '"_dP', {})

--[[ WINDOWS ]]
map({ "n", "t" }, "<C-h>", "<cmd>wincmd h<cr>")
map({ "n", "t" }, "<C-l>", "<cmd>wincmd l<cr>")
map({ "n", "t" }, "<C-j>", "<cmd>wincmd j<cr>")
map({ "n", "t" }, "<C-k>", "<cmd>wincmd k<cr>")

-- add some wincmd shortcuts for terminal mode
map({ "t" }, "<C-w>q", "<cmd>wincmd q<cr>")
map({ "t" }, "<C-w>=", "<cmd>wincmd =<cr>")

map({ "i" }, "<M-h>", "<left>")
map({ "i" }, "<M-l>", "<right>")

map({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

map("n", "<C-o>", "<C-o>zz")
map("n", "<C-i>", "<C-i>zz")
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", {})

-- Remap for dealing with word wrap
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

map("n", "]l", "<cmd>cnext<CR>", {})
map("n", "[l", "<cmd>cprevious<CR>", {})

-- stay in visual mode after indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

map("x", "/", "<esc>/\\%V", { silent = false, desc = "Search inside visual selection" })

map("n", "<S-left>", "<cmd>vertical resize -5<cr>", {})
map("n", "<S-right>", "<cmd>vertical resize +5<cr>", {})
map("n", "<s-up>", "<cmd>resize +2<cr>", {})
map("n", "<s-down>", "<cmd>resize -2<cr>", {})

-- UNDO BREAKPOINTS
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")
map("i", "<cr>", "<cr><c-g>u")

map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
map("n", "<leader>W", "<cmd>w<cr><cmd>restart<cr>", { desc = "Save and restart" })
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })
map("n", "<leader>qr", "<cmd>restart<cr>", { desc = "Restart" })
map("n", "<leader>QQ", "<cmd>qa!<cr>", { desc = "Force Quit all" })
map("n", "<leader>qw", "<cmd>wqa<cr>", { desc = "Quit and save all" })

map("n", "<leader>co", "<cmd>copen<cr>", { desc = "Open Quickfix" })
map("n", "<leader>cc", "<cmd>cclose<cr>", { desc = "Close Quickfix" })

map("n", "<leader>xx", function()
    vim.cmd("w")
    vim.cmd("so %")
end, { desc = "Save and source current file" })

utils.create_cmd_and_map("SourceAllInstances", "<leader>xX", function()
    vim.cmd("w")
    utils.source_in_all_instances()
end, "Save and source current file in all nvim instances")

map("n", "<leader>,r", ":restart<cr>", { desc = "Restart Neovim" })

map("n", "gf", "gF", { desc = "Go to file under cursor at line" })

utils.create_cmd_and_map(
    "ToggleWrap",
    "<leader>tw",
    function() vim.opt.wrap = not vim.opt.wrap:get() end,
    "Toggle line wrap"
)

utils.create_cmd_and_map("BDeleteAll", nil, function() vim.cmd("%bd") end, "Delete All Buffers")

utils.create_cmd_and_map(
    "RelativeNumbersToggle",
    nil,
    function() vim.opt.relativenumber = not vim.opt.relativenumber:get() end,
    "Toggle Relative Numbers"
)

---@return string | nil
local get_gh_repo_url = function()
    local result = vim.system({
        "git",
        "config",
        "--get",
        "remote.origin.url",
    }, { text = true }):wait()

    if result.code ~= 0 or result.stdout == "" then
        vim.notify("Error getting git remote URL")
        return
    end
    if result.stdout then return result.stdout:sub(1, -6) end
end

---@return string | nil
local get_gh_file_url = function()
    local path = vim.fn.expand("%:.")
    local hash = require("config.git").get_merge_base_hash()
    local repo_url = get_gh_repo_url()
    local line_number = vim.api.nvim_win_get_cursor(0)[1]
    if repo_url then return repo_url .. "/blob/" .. hash .. "/" .. path .. "\\#L" .. line_number end
end

---@return nil
local copy_gh_file_url = function()
    local url = get_gh_file_url()
    vim.fn.setreg("+", url)
    vim.notify("Copied to clipboard: " .. url)
end

utils.create_cmd_and_map("CopyGitHubUrlToClipboard", nil, copy_gh_file_url, "Copy GitHub URL to Clipboard")

local open_file_in_gh = function()
    local url = get_gh_file_url()
    vim.cmd("silent !open " .. url)
end

utils.create_cmd_and_map("OpenFileInGitHub", nil, open_file_in_gh, "Open File in Github")

local open_file_in_vscode = function()
    local path = vim.fn.expand("%:p")
    local line = vim.api.nvim_win_get_cursor(0)[1]
    vim.cmd("silent !code -g " .. path .. ":" .. line)
end

utils.create_cmd_and_map("OpenFileInVSCode", "<leader>vs", open_file_in_vscode, "Open File in VS Code")

local open_file_in_obsidian = function() vim.system({ "open", "-a", "Obsidian", vim.fn.expand("%:p") }) end
utils.create_cmd_and_map("OpenFileInObsidian", "<leader>fo", open_file_in_obsidian, "Open File in Obsidian")

local open_repo_in_gh = function()
    local url = get_gh_repo_url()
    vim.cmd("silent !open " .. url)
end

utils.create_cmd_and_map("OpenRepoInGitHub", nil, open_repo_in_gh, "Open Github Repo in Browser")

vim.keymap.set({ "n" }, "<leader>tc", function() vim.cmd("tabnew") end, { desc = "New Tab" })
vim.keymap.set({ "n" }, "<leader>tx", function() vim.cmd("tabclose") end, { desc = "Close Tab" })
vim.keymap.set({ "n", "t" }, "]t", function() vim.cmd("tabnext") end, { desc = "Next Tab" })
vim.keymap.set({ "n", "t" }, "[t", function() vim.cmd("tabp") end, { desc = "Previous Tab" })
vim.keymap.set({ "n" }, "<leader>to", function() vim.cmd("tabonly") end, { desc = "Close Other Tabs" })

utils.create_cmd_and_map("InspectHighlights", nil, function() vim.show_pos() end, "Inspect highlights under cursor")

-- open and focus tmux pane
vim.keymap.set("n", "<C-\\>", function()
    -- if window is zoomed, unzoom, then move focus to right pane
    -- if no addtl pane exists (not zoomed, and rightmost), create and focus it
    vim.cmd([[ silent
      \ !tmux if-shell -F
        \ '\#{?window_zoomed_flag,1,0}'
        \ 'resize-pane -Z'
        \ "if-shell -F
          \ '\#{?pane_at_right,1,0}'
          \ 'split-window -h -l 25\% ; split-window -v -l 80\%; select-pane -R'
          \ '' "
        \ ';'
      \ select-pane -R
    ]])
end, { silent = true })

-- repeat last command in tmux pane
vim.keymap.set("n", "<leader>!!", function()
    -- if zoomed, unzoom, then repeat last command in top right pane
    vim.cmd("write")
    vim.cmd([[ silent
      \ !tmux if-shell -F
        \ '\#{?window_zoomed_flag,1,0}'
        \ 'resize-pane -Z'
        \ '' ';'
      \ send-keys -t {top-right} '\!\!' Enter
    ]])
end, { silent = true })

--- HACK: reopens treesitter context after it's closed by wincmd o
local only = function()
    vim.cmd("only")
    require("treesitter-context").enable()
end

-- wincmd o also zooms tmux pane
vim.keymap.set({ "n", "t" }, "<c-w>o", function()
    -- default behavior
    only()
    -- if unzoomed, zoom
    vim.cmd([[ silent
      \ !tmux if-shell -F
        \ '\#{?window_zoomed_flag,1,0}'
        \ ''
        \ 'resize-pane -Z'
    ]])
end, { silent = true })

utils.create_cmd_and_map("WhichConfig", nil, function() vim.notify(vim.fn.stdpath("config")) end, "Print Config Path")
map("n", "gcT", "<cmd>normal gcATODO: <cr>", { desc = "Add Todo At End Of Line" })
map("n", "gcN", "<cmd>normal gcANOTE: <cr>", { desc = "Add Note At End Of Line" })

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

map(
    "n",
    "]D",
    function()
        vim.diagnostic.jump({
            count = 1,
            float = true,
            severity = vim.diagnostic.severity.ERROR,
        })
    end,
    { desc = "Next Error" }
)
map(
    "n",
    "[D",
    function()
        vim.diagnostic.jump({
            count = -1,
            float = true,
            severity = vim.diagnostic.severity.ERROR,
        })
    end,
    { desc = "Prev Error" }
)
map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Next Diagnostic" })
map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Prev Diagnostic" })

utils.create_cmd_and_map("FocusFloat", "<c-w>f", function()
    for _, winid in ipairs(vim.api.nvim_list_wins()) do
        local config = vim.api.nvim_win_get_config(winid)
        if config.relative ~= "" and config.focusable and not config.hide then
            vim.api.nvim_set_current_win(winid)
            break
        end
    end
end, "Focus Floating Window")

vim.keymap.set("t", "<c-\\><c-\\>", "<C-\\><C-n>", { silent = true, desc = "Exit terminal mode" })

vim.keymap.set(
    "n",
    "<leader>gg",
    function() require("config.git").toggle_lazygit() end,
    { desc = "Open Lazygit Terminal" }
)
vim.keymap.set(
    "n",
    "<leader>gf",
    function() require("config.git").toggle_lazygit({ "-f", vim.trim(vim.api.nvim_buf_get_name(0)) }) end,
    { desc = "Open Lazygit Terminal" }
)

vim.keymap.set("n", "<leader>\\c", function()
    vim.ui.input({
        prompt = "Command:",
    }, function(input)
        if input then
            local cmd = { "zsh" }
            utils.toggle_persistent_terminal(cmd, input, {
                auto_insert = false,
                win_config = {
                    relative = "editor",
                    anchor = "NE",
                    height = math.floor(vim.o.lines * 0.7),
                    width = math.floor(vim.o.columns * 0.4),
                    row = 1,
                    col = vim.o.columns - 1,
                    border = "rounded",
                },
                job_opts = {},
            })

            vim.api.nvim_put({ input, "sleep 2", "exit", "" }, "c", true, true)
        end
    end)
end)

---@return nil
local cwd_filename_to_clipboard = function()
    local filename = vim.fn.expand("%:.")
    vim.fn.setreg("+", filename)
    vim.notify("Copied to clipboard: " .. filename)
end

vim.keymap.set("n", "<leader>rf", cwd_filename_to_clipboard, { desc = "Copy Filename to Clipboard relative to CWD" })

local cwd_filename_with_line_to_clipboard = function()
    local line = vim.api.nvim_win_get_cursor(0)[1]
    local filename_with_line = vim.fn.expand("%:.") .. ":" .. line
    vim.fn.setreg("+", filename_with_line)
    vim.notify("Copied to clipboard: " .. filename_with_line)
end

vim.keymap.set(
    "n",
    "<leader>rF",
    cwd_filename_with_line_to_clipboard,
    { desc = "Copy Filename with Line Number to Clipboard relative to CWD" }
)

---@type string | nil
local diff_first_selection = nil
---@type string | nil
local diff_second_selection = nil

local function open_diff_buf()
    if diff_first_selection == nil or diff_second_selection == nil then
        vim.notify("Diff: both selections must be captured before opening diff.")
        return
    end

    local file1 = vim.fn.tempname()
    local file2 = vim.fn.tempname()
    vim.fn.writefile(vim.split(diff_first_selection, "\n"), file1)
    vim.fn.writefile(vim.split(diff_second_selection, "\n"), file2)

    local cmd = {
        "delta",
        file1,
        file2,
        "--line-numbers",
        "--paging=never",
        "--hunk-header-style=omit",
        "--file-style=omit",
    }

    utils.toggle_persistent_terminal(cmd, "delta_diff_view", {
        q_to_go_back = { "n", "t" },
        auto_insert = false,
        identifier = tostring(vim.fn.localtime()),
    })
end

---@param opts? { range?: number } set if called via command with range
local visual_diff = function(opts)
    opts = opts or {}
    local cur_mode = vim.fn.mode()
    local has_range = opts.range and opts.range > 0

    if cur_mode:find("[vV\22]") or has_range then
        local start_pos, end_pos, region_type
        if cur_mode:find("[vV\22]") then
            -- called from visual mode
            start_pos = vim.fn.getpos("v")
            end_pos = vim.fn.getpos(".")
            region_type = cur_mode
        else
            -- called from command with range
            start_pos = vim.fn.getpos("'<")
            end_pos = vim.fn.getpos("'>")
            region_type = vim.fn.visualmode()
            if region_type == "" then region_type = "v" end
        end

        local lines = vim.fn.getregion(start_pos, end_pos, { type = region_type })
        local text = table.concat(lines, "\n")

        if diff_first_selection ~= nil and diff_second_selection ~= nil then
            -- if both selections are already captured, reset them to start a new diff
            diff_first_selection = nil
            diff_second_selection = nil
        end

        if diff_first_selection == nil then
            diff_first_selection = text
            vim.notify("Diff: first selection captured. Select second text and call function again.")
            return
        end

        diff_second_selection = text
        open_diff_buf()
    else
        -- if called from normal mode without range, try to reopen the last viewed diff
        if diff_first_selection == nil or diff_second_selection == nil then
            vim.notify("Diff: no previous diff to reopen.")
            return
        end
        open_diff_buf()
    end
end

local reset_diff_selections = function()
    diff_first_selection = nil
    diff_second_selection = nil
    vim.notify("Diff: selection cleared.")
end

utils.create_cmd_and_map(
    { name = "DiffSelect", opts = { range = true } },
    { mode = "v", lhs = "<leader>vd", opts = {} },
    visual_diff,
    "Diff visual selection (two-step) / Reopen last diff"
)

vim.keymap.set("n", "<leader>vd", visual_diff, { desc = "Reopen last diff" })

utils.create_cmd_and_map("DiffSelectReset", nil, reset_diff_selections, "Reset diff selection")

vim.keymap.set("n", "<leader>tf", function()
    vim.g.autoformat = not vim.g.autoformat
    vim.notify("Autoformat: " .. (vim.g.autoformat and "Enabled" or "Disabled"))
end, { desc = "Toggle Autoformat" })
