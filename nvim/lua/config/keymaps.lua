local utils = require("config.utils")

local map = function(mode, lhs, rhs, opts)
    opts = vim.tbl_deep_extend("force", { remap = false, silent = true }, opts or {})
    vim.keymap.set(mode, lhs, rhs, opts)
end

pcall(vim.keymap.del, "n", "<leader>w")
pcall(vim.keymap.del, "n", "<leader>wd")
pcall(vim.keymap.del, "n", "<leader>w-")
pcall(vim.keymap.del, "n", "<leader>w|")
pcall(vim.keymap.del, "n", "<leader>wm")

map({ "n", "v" }, "<leader>bd", "<cmd>bdelete<cr>", {})

-- \V - very nomagic
map("n", "<leader>/y", "/\\V<C-r>+<cr>", { desc = "search with contents of + register" })

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

map({ "i" }, "<M-h>", "<left>")
map({ "i" }, "<M-l>", "<right>")

-- stop using arrow keys!!!
map("n", "<up>", "<>", {})
map("n", "<down>", "<>", {})
map("n", "<left>", "<>", {})
map("n", "<right>", "<>", {})

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

utils.create_cmd_and_map(
    "CopyGitHubUrlToClipboard",
    nil,
    function() utils.copy_gh_file_url() end,
    "Copy GitHub URL to Clipboard"
)

utils.create_cmd_and_map("OpenFileInGitHub", nil, function() utils.open_file_in_gh() end, "Open File in Github")

utils.create_cmd_and_map(
    "OpenFileInVSCode",
    "<leader>vs",
    function() utils.open_file_in_vscode() end,
    "Open File in VS Code"
)

utils.create_cmd_and_map("OpenRepoInGitHub", nil, function() utils.open_repo_in_gh() end, "Open Github Repo in Browser")

utils.create_cmd_and_map(nil, "<leader>tc", function() vim.cmd("tabnew") end, "New Tab")
utils.create_cmd_and_map(nil, "<leader>tx", function() vim.cmd("tabclose") end, "Close Tab")
utils.create_cmd_and_map(nil, "]t", function() vim.cmd("tabnext") end, "Next Tab")
utils.create_cmd_and_map(nil, "[t", function() vim.cmd("tabp") end, "Previous Tab")
utils.create_cmd_and_map(nil, "<leader>to", function() vim.cmd("tabonly") end, "Close Other Tabs")

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

-- wincmd o also zooms tmux pane
vim.keymap.set("n", "<c-w>o", function()
    -- default behavior
    vim.cmd("only")
    -- if unzoomed, zoom
    vim.cmd([[ silent
      \ !tmux if-shell -F
        \ '\#{?window_zoomed_flag,1,0}'
        \ ''
        \ 'resize-pane -Z'
    ]])
end, { silent = true })

utils.create_cmd_and_map("WhichConfig", nil, function() vim.notify(vim.fn.stdpath("config")) end, "Print Config Path")
map("n", "gcT", "<cmd>normal gcATODO<cr>", { desc = "Add Comment At End Of Line" }) -- TODO how to return cursor to original position?

--
-- TODO: clean up below, pasted from lazyvim
--

-- Move Lines
map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
map("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

-- commenting
map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Below" })
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })

-- diagnostic
local diagnostic_goto = function(next, severity)
    local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
    severity = severity and vim.diagnostic.severity[severity] or nil
    return function() go({ severity = severity }) end
end
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "]d", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
map("n", "[d", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
map("n", "]D", diagnostic_goto(true), { desc = "Next Diagnostic" })
map("n", "[D", diagnostic_goto(false), { desc = "Prev Diagnostic" })


-- stylua: ignore start

-- toggle options
LazyVim.format.snacks_toggle():map("<leader>uf")
LazyVim.format.snacks_toggle(true):map("<leader>uF")
Snacks.toggle.option("spell", { name = "Spelling"}):map("<leader>us")
Snacks.toggle.diagnostics():map("<leader>ud")
Snacks.toggle.line_number():map("<leader>ul")
Snacks.toggle.option("conceallevel", {off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2}):map("<leader>uc")
Snacks.toggle.treesitter():map("<leader>uT")

map("n", "<leader>gB", function() Snacks.gitbrowse() end, { desc = "Git Browse" })

-- highlights under cursor
map("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
map("n", "<leader>uI", "<cmd>InspectTree<cr>", { desc = "Inspect Tree" })

-- lazyvim end
-- stylua: ignore end

utils.create_cmd_and_map("FocusFloat", "<c-w>f", function()
    for _, winid in ipairs(vim.api.nvim_list_wins()) do
        local config = vim.api.nvim_win_get_config(winid)
        if config.relative ~= "" and config.focusable and not config.hide then
            vim.api.nvim_set_current_win(winid)
            break
        end
    end
end, "Focus Floating Window")

vim.keymap.set("t", "<c-o>", "<C-\\><C-n><C-o>", { desc = "Jump to Normal Mode and Go Back" })
vim.keymap.set("t", "qq", function() utils.safe_close_win(0) end, { silent = true, desc = "Hide terminal buffer" })
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
                q_to_go_back = { "n" },
                auto_insert = false,
                win_config = {
                    split = "right",
                    width = math.floor(vim.o.columns * 0.4),
                },
                job_opts = {},
            })
            -- TODO: this is a hack, figure out the right way to do this
            vim.cmd.startinsert()
            vim.api.nvim_feedkeys(
                vim.api.nvim_replace_termcodes(input .. "<cr><c-\\><c-n>", true, false, true),
                "n",
                false
            )
        end
    end)
end)
