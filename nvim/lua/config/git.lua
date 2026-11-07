local M = {}

---@type string
local git_base = "merge_base"

---@class GitCwdCache
---@field inside_work_tree? boolean
---@field default_branch? string | false # `false` when no default branch could be determined

--- Results of git queries that rarely change, keyed by cwd.
---@type table<string, GitCwdCache>
local cwd_cache = {}

---@return GitCwdCache
local get_cwd_cache = function()
    local cwd = vim.uv.cwd() or ""
    cwd_cache[cwd] = cwd_cache[cwd] or {}
    return cwd_cache[cwd]
end

---@return boolean
M.is_inside_work_tree = function()
    local cache = get_cwd_cache()
    if cache.inside_work_tree == nil then
        local result = vim.system({ "git", "rev-parse", "--is-inside-work-tree" }, { text = true }):wait()
        cache.inside_work_tree = result.code == 0 and vim.trim(result.stdout) == "true"
    end
    return cache.inside_work_tree
end

---@return string
M.get_git_base = function() return git_base end

---@return string | nil
M.get_git_base_hash = function()
    if not M.is_inside_work_tree() or string.lower(git_base) == "head" then return nil end
    if git_base == "merge_base" then return M.get_merge_base_hash() end
    return M.get_rev_hash(git_base)
end

M.change_git_base = function()
    cwd_cache = {}
    vim.ui.select({
        "merge_base",
        "HEAD",
        "HEAD~1",
        "git log",
        "hash",
    }, { prompt = "Select a git base" }, function(selection)
        if selection then
            if selection == "hash" then
                vim.ui.input({
                    prompt = "Enter commit hash: ",
                }, function(input)
                    if input and type(M.get_rev_hash(vim.trim(input))) == "string" then
                        git_base = vim.trim(input)
                        ---@diagnostic disable-next-line: param-type-mismatch
                        require("gitsigns").change_base(M.get_git_base_hash(), true)
                        vim.notify("Git base changed to: " .. git_base, vim.log.levels.INFO)
                    else
                        vim.notify("Invalid git base hash: " .. input, vim.log.levels.WARN)
                    end
                end)
            elseif selection == "git log" then
                Snacks.picker.git_log({
                    confirm = function(picker, item)
                        git_base = item.commit
                        ---@diagnostic disable-next-line: param-type-mismatch
                        require("gitsigns").change_base(M.get_git_base_hash(), true)
                        vim.notify("Git base changed to: " .. git_base, vim.log.levels.INFO)
                        picker:close()
                    end,
                })
            else
                git_base = selection
                ---@diagnostic disable-next-line: param-type-mismatch
                require("gitsigns").change_base(M.get_git_base_hash(), true)
                vim.notify("Git base changed to: " .. git_base, vim.log.levels.INFO)
            end
        else
            vim.notify("Invalid selection", vim.log.levels.WARN)
        end
    end)
end

vim.keymap.set("n", "<leader>gcb", M.change_git_base, { desc = "Change git base" })

--- The branch origin/HEAD points to, falling back to a local main or master branch.
---@return string | nil
M.get_default_branch_name = function()
    local cache = get_cwd_cache()
    if cache.default_branch == nil then
        local origin_head = vim.system(
            { "git", "symbolic-ref", "--short", "refs/remotes/origin/HEAD" },
            { text = true }
        ):wait()
        if origin_head.code == 0 and origin_head.stdout ~= "" then
            cache.default_branch = vim.trim(origin_head.stdout):gsub("^origin/", "")
        else
            local result = vim.system({
                "git",
                "for-each-ref",
                "--format=%(refname:short)",
                "refs/heads/main",
                "refs/heads/master",
            }, { text = true }):wait()

            if result.code ~= 0 then
                vim.notify("Error getting git refs")
                cache.default_branch = false
            elseif result.stdout == "" then
                vim.notify("No main or master branch found", vim.log.levels.INFO)
                cache.default_branch = false
            else
                cache.default_branch = vim.split(result.stdout, "\n")[1]
            end
        end
    end
    return cache.default_branch or nil
end

---@param args string[] | nil
M.toggle_lazygit = function(args)
    local utils = require("config.utils")
    local dotfiles_root = utils.get_dotfiles_root()
    local lazygit_config = dotfiles_root .. "/lazygit/lazygit.yml"

    local cmd = vim.list_extend({ "lazygit" }, args or {})

    local name = args and "lazygit-file" or "lazygit"
    utils.toggle_persistent_terminal(cmd, name, {
        identifier = args and table.concat(args, " ") or nil,
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
    local default_branch = M.get_default_branch_name()
    if not default_branch then return nil end
    local result = vim.system({ "git", "merge-base", default_branch, "HEAD" }, { text = true }):wait()
    if result.code ~= 0 then
        vim.notify("Error getting merge base hash", vim.log.levels.DEBUG)
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

---@return string[] # absolute paths of every worktree of the current repo
M.get_worktree_paths = function()
    local result = vim.system({ "git", "worktree", "list", "--porcelain" }, { text = true }):wait()
    if result.code ~= 0 then return {} end

    local paths = {}
    for _, line in ipairs(vim.split(result.stdout, "\n")) do
        local path = line:match("^worktree (.+)$")
        if path then table.insert(paths, path) end
    end
    return paths
end

M.get_worktree_panes = function()
    local result = vim.system({
        "node",
        require("config.utils").get_dotfiles_root() .. "/scripts/tmux-worktrees.ts",
    }, { text = true }):wait()

    if result.code ~= 0 or result.stdout == "" then
        vim.notify("Error getting worktree panes")
        return
    end
    local output = result.stdout or ""
    local worktrees_map = {}
    local worktrees_opts = {}
    for _, line_str in ipairs(vim.split(output, "\n")) do
        local line = vim.split(line_str, " ")
        if #line > 1 then
            local key = line[1] .. " [" .. line[2] .. "]"
            table.insert(worktrees_opts, key)
            worktrees_map[key] = {
                branch = line[1],
                path = line[2],
                session = line[3],
                window_index = line[4],
                pane_index = line[5],
                command = line[6],
            }
        end
    end
    return worktrees_map, worktrees_opts
end

M.switch_worktree_pane = function()
    local worktrees_map, worktrees_opts = M.get_worktree_panes()
    if not worktrees_map or vim.tbl_isempty(worktrees_map) then
        vim.notify("No worktree panes found", vim.log.levels.INFO)
        return
    end

    vim.ui.select(worktrees_opts or {}, {
        prompt = "Select worktree pane: ",
    }, function(choice)
        if choice then
            local wt = worktrees_map[choice]
            vim.cmd("silent !tmux switch-client -t " .. wt.session .. ":" .. wt.window_index .. "." .. wt.pane_index)
        end
    end)
end

vim.keymap.set("n", "<leader>gt", M.switch_worktree_pane, { desc = "Switch to git worktree pane" })

return M
