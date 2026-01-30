local ai_cli_options = {
    claude = { "claude" },
    opencode = { "opencode" },
    gemini = { "gemini" },
}

local default_ai_cli = ai_cli_options.claude
local ai_chat_cli = "claude_haiku"

---@class ToggleAICLIOptions
---@field cmd? string[]
---@field if_exists? "use_existing" | "replace" | "keep_both"
---@field text? string[]

---@param opts? ToggleAICLIOptions
local toggle_ai_cli = function(opts)
    opts = opts or {}

    require("config.utils").toggle_persistent_terminal(opts.cmd or default_ai_cli, "ai_cli", {
        q_to_go_back = { "n" },
        auto_insert = true,
        if_exists = opts.if_exists or "use_existing",
        win_config = require("config.utils").get_responsive_win_config(),
        cb = opts.text and function() vim.api.nvim_put(opts.text, "c", true, true) end or nil,
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

return {
    {
        "https://github.com/CopilotC-Nvim/CopilotChat.nvim",
        event = "VeryLazy",
        enabled = false,
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
    },
}
