local ai_cli_options = {
    claude = { "claude", "--continue" },
    opencode = { "opencode" },
    gemini = { "gemini" },
}

local default_ai_cli = ai_cli_options.claude

---@class ToggleAICLIOptions
---@field cmd? string[]
---@field if_exists? "use_existing" | "replace" | "keep_both"
---@field text? string[]

---@param opts? ToggleAICLIOptions
local toggle_ai_cli = function(opts)
    opts = opts or {}

    require("config.utils").toggle_persistent_terminal(opts.cmd or default_ai_cli, "ai_cli", {
        q_to_go_back = { "n" },
        auto_insert = false,
        if_exists = opts.if_exists or "use_existing",
        win_config = require("config.utils").get_responsive_win_config(),
        job_opts = {
            env = {
                CLAUDE_CODE_TASK_LIST_ID = vim.uv.cwd(),
                EDITOR = 'nvim --server "$NVIM" --remote',
            },
        },
        cb_on_every = opts.text and function() vim.api.nvim_put(opts.text, "c", true, true) end or nil,
        cb_on_create = function(term_bufnr)
            vim.keymap.set("t", "<c-u>", "<c-\\><c-n><c-u>", { buffer = term_bufnr })
            vim.keymap.set("t", "<c-d>", "<c-\\><c-n><c-d>", { buffer = term_bufnr })
            vim.cmd.startinsert()
        end,
    })
end

vim.keymap.set("n", "<leader>aa", toggle_ai_cli, { desc = "Open AI CLI" })

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
                if_exists = "replace",
            })
        end
    end)
end, { desc = "Select AI CLI" })

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
