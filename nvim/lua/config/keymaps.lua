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

map("n", "<leader>w", "<cmd>w<cr>", { desc = ":w" })
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })
map("n", "<leader>QQ", "<cmd>qa!<cr>", { desc = "Force Quit all" })
map("n", "<leader>qw", "<cmd>wqa<cr>", { desc = "Quit and save all" })

map("n", "<leader>co", "<cmd>copen<cr>", { desc = "Open Quickfix" })
map("n", "<leader>cc", "<cmd>cclose<cr>", { desc = "Close Quickfix" })

map("n", "<leader>xx", function()
    vim.cmd("w")
    vim.cmd("so %")
end, { desc = "Save and source current file" })

utils.create_cmd_and_map(
    "ToggleWrap",
    "<leader>tw",
    function() vim.opt.wrap = not vim.opt.wrap:get() end,
    "Toggle line wrap"
)

utils.create_cmd_and_map("BDeleteAll", nil, function() vim.cmd("%bd") end, "Delete All Buffers")

utils.create_cmd_and_map(
    "RelativeNumbersToggle",
    "<leader>tn",
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

utils.create_cmd_and_map("OpenFileInVSCode", nil, function() utils.open_file_in_vscode() end, "Open File in VS Code")

utils.create_cmd_and_map("OpenRepoInGitHub", nil, function() utils.open_repo_in_gh() end, "Open Github Repo in Browser")

utils.create_cmd_and_map("EnableDiagnosticsCurrentBuffer", nil, function() vim.diagnostic.enable(0) end)

utils.create_cmd_and_map("DisableDiagnosticsCurrentBuffer", nil, function() vim.diagnostic.disable(0) end)

-- utils.create_cmd_and_map(nil, nil, function() vim.cmd('copen') end, 'Open Quickfix')
-- utils.create_cmd_and_map(nil, nil, function() vim.cmd('lopen') end, 'Open Location list')

utils.create_cmd_and_map(nil, "<leader><tab>c", function() vim.cmd("tabnew") end, "New Tab")
utils.create_cmd_and_map(nil, "<leader><tab>x", function() vim.cmd("tabclose") end, "Close Tab")
utils.create_cmd_and_map(nil, "<leader><tab>n", function() vim.cmd("tabnext") end, "Next Tab")
utils.create_cmd_and_map(nil, "<leader><tab>p", function() vim.cmd("tabp") end, "Previous Tab")

utils.create_cmd_and_map(nil, { mode = { "t" }, lhs = "<esc><esc>" }, "<c-\\><c-n>")
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

-- TODO: clean up below, pasted from lazyvim

-- Move Lines
map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
map("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<leader>bd", function() Snacks.bufdelete() end, { desc = "Delete Buffer" })
map("n", "<leader>bo", function() Snacks.bufdelete.other() end, { desc = "Delete Other Buffers" })
map("n", "<leader>bD", "<cmd>:bd<cr>", { desc = "Delete Buffer and Window" })

-- Clear search with <esc>
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and Clear hlsearch" })

-- Clear search, diff update and redraw
-- taken from runtime/lua/_editor.lua
map(
    "n",
    "<leader>ur",
    "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
    { desc = "Redraw / Clear hlsearch / Diff Update" }
)

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

--keywordprg
map("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "Keywordprg" })

-- commenting
map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Below" })
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })

-- formatting
map({ "n", "v" }, "<leader>cf", function() LazyVim.format({ force = true }) end, { desc = "Format" })

-- diagnostic
local diagnostic_goto = function(next, severity)
    local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
    severity = severity and vim.diagnostic.severity[severity] or nil
    return function() go({ severity = severity }) end
end
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
map("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

-- stylua: ignore start

-- toggle options
LazyVim.format.snacks_toggle():map("<leader>uf")
LazyVim.format.snacks_toggle(true):map("<leader>uF")
Snacks.toggle.option("spell", { name = "Spelling"}):map("<leader>us")
Snacks.toggle.option("wrap", {name = "Wrap"}):map("<leader>uw")
Snacks.toggle.option("relativenumber", { name = "Relative Number"}):map("<leader>uL")
Snacks.toggle.diagnostics():map("<leader>ud")
Snacks.toggle.line_number():map("<leader>ul")
Snacks.toggle.option("conceallevel", {off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2}):map("<leader>uc")
Snacks.toggle.treesitter():map("<leader>uT")
Snacks.toggle.option("background", { off = "light", on = "dark" , name = "Dark Background"}):map("<leader>ub")
if vim.lsp.inlay_hint then
  Snacks.toggle.inlay_hints():map("<leader>uh")
end

-- lazygit
if vim.fn.executable("lazygit") == 1 then
  map("n", "<leader>gg", function() Snacks.lazygit( { cwd = LazyVim.root.git() }) end, { desc = "Lazygit (Root Dir)" })
  map("n", "<leader>gG", function() Snacks.lazygit() end, { desc = "Lazygit (cwd)" })
  map("n", "<leader>gb", function() Snacks.git.blame_line() end, { desc = "Git Blame Line" })
  map("n", "<leader>gB", function() Snacks.gitbrowse() end, { desc = "Git Browse" })
  map("n", "<leader>gf", function() Snacks.lazygit.log_file() end, { desc = "Lazygit Current File History" })
  map("n", "<leader>gl", function() Snacks.lazygit.log({ cwd = LazyVim.root.git() }) end, { desc = "Lazygit Log" })
  map("n", "<leader>gL", function() Snacks.lazygit.log() end, { desc = "Lazygit Log (cwd)" })
end


-- highlights under cursor
map("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
map("n", "<leader>uI", "<cmd>InspectTree<cr>", { desc = "Inspect Tree" })

-- floating terminal
map("n", "<leader>fT", function() Snacks.terminal() end, { desc = "Terminal (cwd)" })
map("n", "<leader>ft", function() Snacks.terminal(nil, { cwd = LazyVim.root() }) end, { desc = "Terminal (Root Dir)" })
map("n", "<c-/>",      function() Snacks.terminal(nil, { cwd = LazyVim.root() }) end, { desc = "Terminal (Root Dir)" })
map("n", "<c-_>",      function() Snacks.terminal(nil, { cwd = LazyVim.root() }) end, { desc = "which_key_ignore" })

-- Terminal Mappings
map("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })
map("t", "<c-_>", "<cmd>close<cr>", { desc = "which_key_ignore" })

-- windows
map("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })
map("n", "<leader>wd", "<C-W>c", { desc = "Delete Window", remap = true })
LazyVim.ui.maximize():map("<leader>wm")

-- tabs
map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
map("n", "<leader><tab>o", "<cmd>tabonly<cr>", { desc = "Close Other Tabs" })
map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- native snippets. only needed on < 0.11, as 0.11 creates these by default
if vim.fn.has("nvim-0.11") == 0 then
  map("s", "<Tab>", function()
    return vim.snippet.active({ direction = 1 }) and "<cmd>lua vim.snippet.jump(1)<cr>" or "<Tab>"
  end, { expr = true, desc = "Jump Next" })
  map({ "i", "s" }, "<S-Tab>", function()
    return vim.snippet.active({ direction = -1 }) and "<cmd>lua vim.snippet.jump(-1)<cr>" or "<S-Tab>"
  end, { expr = true, desc = "Jump Previous" })
end
