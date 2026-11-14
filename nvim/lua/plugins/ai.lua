---@type table<string, table<string> | function>
local ai_cli_options = {
    claude = { "claude" },
    claude_opus_4_8 = { "claude", "--model", "claude-opus-4-8[1m]" },
    claude_resume = {},
    opencode = { "opencode" },
    codex = { "codex" },
    sbx = { "sbx" }, -- use ../*.sbxenv.yaml files
}

---@class ToggleAICLIOptions
---@field cmd string[]
---@field text? string[]
---@field namespace? string
---@field cwd? string # directory to start the CLI in, defaults to nvim's cwd

--- Opens the file under the cursor at its line number (like `gF`) in another window, so the AI CLI stays visible.
--- Reuses the previous window if it's a non-terminal split in the current tab, otherwise the first such split,
--- otherwise creates a vertical split to the left.
local goto_file_in_split = function()
    local term_win = vim.api.nvim_get_current_win()

    ---@type integer[]
    local candidate_wins = vim.tbl_filter(
        function(win)
            return win ~= term_win
                and vim.api.nvim_win_get_config(win).relative == ""
                and vim.bo[vim.api.nvim_win_get_buf(win)].buftype ~= "terminal"
        end,
        vim.api.nvim_tabpage_list_wins(0)
    )

    if #candidate_wins == 0 then
        vim.cmd("leftabove vertical wincmd F")
        return
    end

    local previous_win = vim.fn.win_getid(vim.fn.winnr("#"))
    local target_win = vim.tbl_contains(candidate_wins, previous_win) and previous_win or candidate_wins[1]

    -- `wincmd F` resolves the file and line the same way `gF` does; open it in a temporary split, then move it
    vim.cmd("wincmd F")
    local file_buf = vim.api.nvim_get_current_buf()
    local cursor = vim.api.nvim_win_get_cursor(0)
    vim.api.nvim_win_close(0, false)

    vim.api.nvim_set_current_win(target_win)
    vim.cmd.buffer(file_buf)
    vim.api.nvim_win_set_cursor(target_win, cursor)
end

---@param opts? ToggleAICLIOptions
local toggle_ai_cli = function(opts)
    opts = opts or {}
    local cwd = opts.cwd or vim.uv.cwd()

    local default_ai_cli = ai_cli_options[require("config.settings").default_ai_cli] or ai_cli_options.claude
    local cmd = {}
    vim.list_extend(cmd, opts.cmd or default_ai_cli)

    if cmd[1] == "sbx" then
        vim.list_extend(cmd, {
            "env",
            "run",
            "../.sbxenv/" .. require("config.utils").get_path_tail(vim.loop.cwd()) .. ".sbxenv.yaml",
            "../.sbxenv/base.sbxenv.yaml",
        })
    end

    require("config.utils").toggle_persistent_terminal(cmd, opts.namespace or "ai_cli", {
        q_to_go_back = { "n" },
        auto_insert = false,
        win_config = require("config.utils").get_responsive_win_config(),
        job_opts = {
            cwd = cwd,
            env = {
                CLAUDE_CODE_TASK_LIST_ID = cwd,
                EDITOR = "sh " .. require("config.utils").get_dotfiles_root() .. "/scripts/neovim-remote",
            },
        },
        cb_on_every = opts.text and function() vim.api.nvim_put(opts.text, "c", true, true) end or nil,
        cb_on_create = function(term_bufnr)
            local passthrough_keys = {}
            local codex_passthru_keys = { "<c-t>" }
            if cmd[1] == "codex" then vim.list_extend(passthrough_keys, codex_passthru_keys) end

            local claude_passthru_keys = { "1", "2", "3", "4", "<c-g>", "<s-tab>", "<c-t>" }
            if cmd[1] == "claude" then vim.list_extend(passthrough_keys, claude_passthru_keys) end

            for _, key in ipairs(passthrough_keys) do
                vim.keymap.set("n", key, function()
                    vim.cmd.startinsert()
                    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), "n", false)
                    vim.schedule(function() vim.cmd.stopinsert() end)
                end, { buffer = term_bufnr })
            end

            vim.keymap.set("t", "<c-u>", "<c-\\><c-n><c-u>", { buffer = term_bufnr })
            vim.keymap.set("t", "<c-d>", "<c-\\><c-n><c-d>", { buffer = term_bufnr })
            vim.keymap.set(
                "n",
                "gf",
                goto_file_in_split,
                { buffer = term_bufnr, desc = "Go to file under cursor at line in split" }
            )
            vim.cmd.startinsert()
        end,
    })
end

local pick_ai_cli = function()
    vim.ui.select(vim.tbl_keys(ai_cli_options), {
        prompt = "Select AI CLI:",
    }, function(choice)
        if choice then
            toggle_ai_cli({
                cmd = ai_cli_options[choice],
                namespace = "ai_cli_" .. choice .. ":" .. tostring(vim.fn.localtime()),
            })
        end
    end)
end

-- Opens AI CLI terminals not already visible in the current tab as vertical
-- splits. Falls back to `toggle_ai_cli` when none exist yet.
local open_all_ai_clis = function()
    local ai_bufs = {}
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_get_name(buf):find("term://ai_cli", nil, true) then table.insert(ai_bufs, buf) end
    end

    if #ai_bufs == 0 then
        toggle_ai_cli()
        return
    end

    local visible_bufs = {}
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        visible_bufs[vim.api.nvim_win_get_buf(win)] = true
    end

    for _, buf in ipairs(ai_bufs) do
        if not visible_bufs[buf] then vim.api.nvim_open_win(buf, true, { split = "right" }) end
    end

    vim.cmd("wincmd =")
end

vim.keymap.set("n", "<leader>aa", open_all_ai_clis, { desc = "Open all AI CLIs" })

vim.keymap.set(
    "n",
    "<leader>af",
    function()
        toggle_ai_cli({
            text = { "@" .. vim.fn.expand("%:.") },
        })
    end,
    { desc = "Send filename to AI CLI" }
)

vim.keymap.set("n", "<leader>aA", pick_ai_cli, { desc = "Select AI CLI" })

--- Claude Code stores sessions in ~/.claude/projects/<session cwd with non-alphanumerics replaced by "-">/
---@param path string
---@return string
local get_claude_project_dir = function(path)
    return vim.fs.normalize(vim.fs.joinpath(vim.env.HOME, ".claude", "projects", (path:gsub("[^%w]", "-"))))
end

--- Live greps the Claude Code sessions of every worktree of the current repo, resuming the selected session
local grep_claude_sessions = function()
    ---@type table<string, string> # Claude project dir -> worktree path
    local worktree_by_project_dir = {}
    for _, path in ipairs(require("config.git").get_worktree_paths()) do
        local project_dir = get_claude_project_dir(path)
        if vim.uv.fs_stat(project_dir) then worktree_by_project_dir[project_dir] = path end
    end

    if vim.tbl_isempty(worktree_by_project_dir) then
        vim.notify("No Claude sessions found for this repo's worktrees", vim.log.levels.INFO)
        return
    end

    Snacks.picker.grep({
        title = "Claude sessions",
        dirs = vim.tbl_keys(worktree_by_project_dir),
        glob = "*.jsonl",
        args = {
            -- skip subagent transcripts in <session id>/subagents/, which can't be resumed
            "--max-depth=1",
            -- JSONL lines are long; keep the whole line so the match can be shown in `format`
            "--max-columns=0",
        },
        -- show the worktree and a snippet around the first match instead of the start of the JSON line
        format = function(item, picker)
            local first_match = item.positions and item.positions[1] or 1
            local start = math.max(1, first_match - 60)
            local positions = item.positions
                and vim.tbl_filter(
                    function(p) return p > 0 end,
                    vim.tbl_map(function(p) return p - start + 1 end, item.positions)
                )
            local display_item = setmetatable({
                label = vim.fs.basename(worktree_by_project_dir[vim.fs.dirname(item.file)] or ""),
                line = item.line and item.line:sub(start, start + 200),
                positions = positions,
            }, { __index = item })
            return Snacks.picker.format.file(display_item, picker)
        end,
        confirm = function(picker, item)
            picker:close()
            if not item then return end
            local session_id = vim.fn.fnamemodify(item.file, ":t:r")
            toggle_ai_cli({
                cmd = { "claude", "--resume", session_id },
                cwd = worktree_by_project_dir[vim.fs.dirname(item.file)],
                namespace = "ai_cli_claude:" .. session_id,
            })
        end,
    })
end

vim.keymap.set("n", "<leader>fc", grep_claude_sessions, { desc = "[F]ind [C]laude sessions in repo worktrees" })

vim.keymap.set(
    "n",
    "<leader>aC",
    function()
        toggle_ai_cli({
            cmd = ai_cli_options.claude,
            namespace = "ai_cli_claude" .. ":" .. tostring(vim.fn.localtime()),
        })
    end,
    { desc = "New Claude CLI" }
)

---@module 'lazy'
---@type LazySpec
return {
    {
        "https://github.com/CopilotC-Nvim/CopilotChat.nvim",
        event = "VeryLazy",
        enabled = false,
        dependencies = {
            "https://github.com/nvim-lua/plenary.nvim",
        },
    },
}
