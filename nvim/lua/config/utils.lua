local git_lazy = require("lazy.manage.git")
local M = {}

M.test_function = function(arg) require("notify").notify(arg or "TESTING", "ERROR", {}) end

---@class User_Command
---@field name string
---@field opts table

---@class Mapping
---@field mode table|string
---@field lhs string
---@field opts table

---@param command? string|User_Command # Name of command as a string, or a table containing name and opts.
---@param mapping? string|Mapping # Normal mode mapping as a string, or a table containing mode, lhs, and opts.
---@param fn fun()|string
---@param desc? string
M.create_cmd_and_map = function(command, mapping, fn, desc)
    local desc_with_fallback = desc
    if not desc_with_fallback then
        if command and command.name then
            desc_with_fallback = command.name
        elseif type(command) == "string" then
            desc_with_fallback = command
        else
            desc_with_fallback = ""
        end
    end

    if type(command) == "string" then
        vim.api.nvim_create_user_command(command, fn, { desc = desc_with_fallback })
    elseif type(command) == "table" then
        if command.name then
            if not command.opts.desc then command.opts.desc = desc_with_fallback end
            vim.api.nvim_create_user_command(command.name, fn, command.opts)
        end
    end

    if type(mapping) == "string" then
        vim.keymap.set("n", mapping, fn, { desc = desc_with_fallback })
    elseif type(mapping) == "table" then
        if mapping.lhs then
            local opts = vim.tbl_deep_extend("force", {
                remap = false,
                silent = true,
                desc = desc_with_fallback,
            }, mapping.opts or {})
            vim.keymap.set(mapping.mode or "n", mapping.lhs, fn, opts)
        end
    end
end

---@alias branch 'main' | 'master'
---@return branch | nil
M.get_default_branch_name = function()
    local root = Snacks.git.get_root()
    if not root then
        vim.notify("Error getting default branch name: no git root found")
        return
    end
    local git_config = git_lazy.get_config(root)
    if git_config["branch.main.remote"] then
        return "main"
    elseif git_config["branch.master.remote"] then
        return "master"
    else
        logger("Error getting default branch name from config " .. vim.inspect(git_config))
    end
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

---@return string | nil
M.get_commit_hash = function()
    local result = vim.system({ "git", "rev-parse", "HEAD" }, { text = true }):wait()
    if result.code ~= 0 then
        vim.notify("Error getting commit hash")
        return
    end
    return result.stdout:sub(1, -2)
end

---@return string | nil
M.get_gh_repo_url = function()
    local root = Snacks.git.get_root()
    if not root then
        vim.notify("Error getting default branch name: no git root found")
        return
    end
    local git_config = git_lazy.get_config(root)
    local repo_url = git_config["remote.origin.url"]
    if repo_url then return repo_url:sub(1, -5) end
end

---@return string | nil
M.get_gh_file_url = function()
    local path = vim.fn.expand("%:.")
    local hash = M.get_commit_hash()
    local repo_url = M.get_gh_repo_url()
    local line_number = vim.api.nvim_win_get_cursor(0)[1]
    if repo_url then return repo_url .. "/blob/" .. hash .. "/" .. path .. "\\#L" .. line_number end
end

M.open_file_in_vscode = function()
    local path = vim.fn.expand("%:p")
    local line = vim.api.nvim_win_get_cursor(0)[1]
    vim.cmd("silent !code -g " .. path .. ":" .. line)
end

---@return nil
M.copy_gh_file_url = function()
    local url = M.get_gh_file_url()
    vim.fn.setreg("+", url)
    vim.notify("Copied to clipboard: " .. url)
end

M.open_file_in_gh = function()
    local url = M.get_gh_file_url()
    vim.cmd("silent !open " .. url)
end

M.open_repo_in_gh = function()
    local url = M.get_gh_repo_url()
    vim.cmd("silent !open " .. url)
end

M.is_system_dark_mode = function()
    if string.find(vim.fn.system("defaults read -globalDomain AppleInterfaceStyle 2>/dev/null"), "Dark") then
        return true
    else
        return false
    end
end

M.get_path_tail = function(path)
    for i = #path, 1, -1 do
        if path:sub(i, i) == "/" then return path:sub(i + 1, -1) end
    end
    return path
end

M.augroup = function(name) return vim.api.nvim_create_augroup("user_" .. name, { clear = true }) end

return M
