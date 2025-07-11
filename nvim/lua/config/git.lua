local utils = require("config.utils")
local M = {}

M.toggle_lazygit = function(args)
    local dotfiles_root = utils.get_dotfiles_root()
    local lazygit_config = dotfiles_root .. "/lazygit/lazygit.yml"
    if not utils.is_system_dark_mode() then
        lazygit_config = lazygit_config .. "," .. dotfiles_root .. "/lazygit/light.yml"
    end

    local cmd = vim.list_extend({ "lazygit" }, args or {})

    utils.toggle_persistent_terminal(cmd, "Lazygit", {
        q_to_go_back = { "n", "t" },
        auto_insert = true,
        win_config = {
            relative = "editor",
            height = vim.o.lines - 2,
            width = vim.o.columns,
            row = 1,
            col = 1,
        },
        job_opts = { env = {
            LG_CONFIG_FILE = lazygit_config,
        } },
    })
end

return M
