local M = {}

local git_base = ""

M.get_git_base = function()
    if git_base == "" then git_base = M.get_merge_base_hash() or "HEAD" end
    return git_base
end

M.change_git_base = function()
    vim.ui.select({
        M.get_default_branch_name() .. "..." .. "HEAD",
        "HEAD",
    }, { prompt = "Select a git base" }, function(selection)
        if selection then
            git_base = selection
            require("gitsigns").change_base(selection, true)
        end
    end)
end

vim.keymap.set("n", "<leader>gcb", M.change_git_base, { desc = "Change git base" })

---@alias branch 'main' | 'master'
---@return branch | nil
M.get_default_branch_name = function()
    local result = vim.system({
        "git",
        "for-each-ref",
        "--format=%(refname:short)",
        "refs/heads/main",
        "refs/heads/master",
    }, { text = true }):wait()

    if result.code ~= 0 then
        vim.notify("Error getting git refs")
        return
    end
    if result.stdout == "" then
        vim.notify("No main or master branch found")
        return
    end
    return result.stdout:sub(1, -2)
end

M.toggle_lazygit = function(args)
    local utils = require("config.utils")
    local dotfiles_root = utils.get_dotfiles_root()
    local lazygit_config = dotfiles_root .. "/lazygit/lazygit.yml"
    if not utils.is_system_dark_mode() then
        lazygit_config = lazygit_config .. "," .. dotfiles_root .. "/lazygit/light.yml"
    end

    local cmd = vim.list_extend({ "lazygit" }, args or {})

    utils.toggle_persistent_terminal(cmd, "Lazygit", {
        q_to_go_back = { "n" },
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

---@return string | nil
M.get_merge_base_hash = function()
    local result = vim.system({ "git", "merge-base", M.get_default_branch_name(), "HEAD" }, { text = true }):wait()
    if result.code ~= 0 then
        vim.notify("Error getting merge base hash")
        return
    end
    return result.stdout:sub(1, -2)
end

return M
