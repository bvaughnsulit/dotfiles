local ai_cli_options = {
    claude = { "claude" },
    opencode = { "opencode" },
    gemini = { "gemini" },
    codex = { "codex" },
}

---@class ToggleAICLIOptions
---@field cmd? string[]
---@field text? string[]
---@field namespace? string

---@param opts? ToggleAICLIOptions
local toggle_ai_cli = function(opts)
    opts = opts or {}

    local default_ai_cli = ai_cli_options[require("config.settings").default_ai_cli] or ai_cli_options.claude
    local cmd = {}
    vim.list_extend(cmd, opts.cmd or default_ai_cli)

    if cmd[1] == "claude" then
        local claude_args = {
            "--add-dir",
            require("config.utils").get_dotfiles_root() .. "/claude",
        }
        vim.list_extend(claude_args, require("config.settings").claude_args)
        vim.list_extend(cmd, claude_args)
    end

    require("config.utils").toggle_persistent_terminal(cmd, opts.namespace or "ai_cli", {
        q_to_go_back = { "n" },
        auto_insert = false,
        win_config = require("config.utils").get_responsive_win_config(),
        job_opts = {
            env = {
                CLAUDE_CODE_TASK_LIST_ID = vim.uv.cwd(),
                EDITOR = "sh " .. require("config.utils").get_dotfiles_root() .. "/scripts/neovim-remote",
            },
        },
        cb_on_every = opts.text and function() vim.api.nvim_put(opts.text, "c", true, true) end or nil,
        cb_on_create = function(term_bufnr)
            local passthrough_keys = {}
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
            vim.cmd.startinsert()
        end,
    })
end

-- Opens every existing `ai_cli` terminal stacked top-to-bottom inside a single
-- vertical split. Falls back to `toggle_ai_cli` when none exist yet.
local open_all_ai_clis = function()
    local ai_bufs = {}
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_get_name(buf):find("term://ai_cli", nil, true) then table.insert(ai_bufs, buf) end
    end

    if #ai_bufs == 0 then
        toggle_ai_cli()
        return
    end

    -- Detach these buffers from any window currently showing them so the panel
    -- is the only place they live.
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.tbl_contains(ai_bufs, vim.api.nvim_win_get_buf(win)) then require("config.utils").safe_close_win(win) end
    end

    vim.api.nvim_open_win(ai_bufs[1], true, {
        split = "right",
        width = math.floor(vim.o.columns * 0.4),
    })

    for i = 2, #ai_bufs do
        vim.api.nvim_open_win(ai_bufs[i], true, { split = "below" })
    end
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

vim.keymap.set("n", "<leader>aA", function()
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
end, { desc = "Select AI CLI" })

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
