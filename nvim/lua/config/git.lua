local M = {}

---@type string | nil
local git_base = "merge_base"

---@return {name: string | nil, hash: string | nil}
M.get_git_base = function()
    local hash

    local result = vim.system({ "git", "rev-parse", "--is-inside-work-tree" }, { text = true }):wait()

    if result.code ~= 0 or result.stdout:sub(1, -2) ~= "true" then
        hash = nil
        git_base = nil
    end

    if git_base then
        if string.lower(git_base) == "head" then
            hash = nil
        elseif git_base == "merge_base" then
            hash = M.get_merge_base_hash()
        else
            hash = M.get_rev_hash(git_base)
        end
    end

    return {
        name = git_base,
        hash = hash,
    }
end

M.change_git_base = function()
    vim.ui.select({
        "merge_base",
        "HEAD",
        "custom",
    }, { prompt = "Select a git base" }, function(selection)
        if selection then
            if selection == "custom" then
                vim.ui.input({
                    prompt = "Enter custom git base",
                }, function(input)
                    if input and type(M.get_rev_hash(vim.trim(input))) == "string" then
                        git_base = vim.trim(input)
                        ---@diagnostic disable-next-line: param-type-mismatch
                        require("gitsigns").change_base(M.get_git_base().hash, true)
                        vim.notify("Git base changed to: " .. git_base, vim.log.levels.INFO)
                    else
                        vim.notify("Invalid git base hash: " .. input, vim.log.levels.WARN)
                    end
                end)
            else
                git_base = selection
                ---@diagnostic disable-next-line: param-type-mismatch
                require("gitsigns").change_base(M.get_git_base().hash, true)
                vim.notify("Git base changed to: " .. git_base, vim.log.levels.INFO)
            end
        else
            vim.notify("Invalid selection", vim.log.levels.WARN)
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
        return nil
    end
    return result.stdout:sub(1, -2)
end

---@param rev string
---@return string | nil
M.get_rev_hash = function(rev)
    local result = vim.system({ "git", "rev-parse", rev }, { text = true }):wait()
    if result.code ~= 0 then
        vim.notify("Error getting rev hash for " .. git_base)
        return nil
    end
    return result.stdout:sub(1, -2)
end

return M
