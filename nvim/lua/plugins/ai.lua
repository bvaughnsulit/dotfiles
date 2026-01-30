local ai_cli_options = {
    claude = { "claude" },
    opencode = { "opencode" },
    gemini = { "gemini" },
}

local default_ai_cli = ai_cli_options.claude
local ai_chat_cli = "claude_haiku"

local toggle_ai_cli = function(cmd, if_exists)
    require("config.utils").toggle_persistent_terminal(cmd or default_ai_cli, "ai_cli", {
        q_to_go_back = { "n" },
        auto_insert = true,
        if_exists = if_exists or "use_existing",
        win_config = {
            split = "right",
        },
        -- job_opts = { env = {} },
    })
end
vim.keymap.set("n", "<leader>aa", toggle_ai_cli, { desc = "Open AI CLI" })

vim.keymap.set("n", "<leader>aA", function()
    vim.ui.select(vim.tbl_keys(ai_cli_options), {
        prompt = "Select AI CLI:",
    }, function(choice)
        if choice then toggle_ai_cli(ai_cli_options[choice], "replace") end
    end)
end, { desc = "Select AI CLI" })

return {
    {
        "https://github.com/CopilotC-Nvim/CopilotChat.nvim",
        event = "VeryLazy",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
    },
}
