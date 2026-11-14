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

--- Like `get_git_base_hash`, but resolves a HEAD base to "HEAD" instead of nil, for tools that need an
--- explicit revision (gitsigns treats nil as the index; deltaview treats a missing ref as its last-used ref).
---@return string
M.get_git_base_rev = function() return M.get_git_base_hash() or "HEAD" end

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

--- Opens DeltaView on the current file against the persisted git base.
M.open_deltaview = function() vim.cmd.DeltaView(M.get_git_base_rev()) end

--- Populates the quickfix list with files changed since the persisted git base.
M.open_deltamenu_quickfix = function() vim.cmd.DeltaMenu({ args = { M.get_git_base_rev() }, bang = true }) end

---@class HunkTarget
---@field path string # absolute path of the file, as named by the buffer
---@field lnum integer # worktree line under the cursor; on a deleted line, the worktree line it was deleted after (0 = top)
---@field on_deleted_line boolean # cursor is on a deltaview "removed" line, which has no worktree line
---@field single_file_deltaview boolean # cursor is in a `:DeltaView` buffer, which can be rebuilt after committing

---@class UnstagedHunk
---@field new_start integer
---@field new_count integer
---@field lines string[] # the `@@` header followed by the hunk body

---@param bufnr integer
---@return HunkTarget | nil
local get_buffer_hunk_target = function(bufnr)
    if vim.bo[bufnr].buftype ~= "" then
        vim.notify("Not a file buffer", vim.log.levels.WARN)
        return nil
    end
    if vim.bo[bufnr].modified then
        vim.notify("Save the buffer before committing a hunk", vim.log.levels.WARN)
        return nil
    end
    return {
        path = vim.api.nvim_buf_get_name(bufnr),
        lnum = vim.api.nvim_win_get_cursor(0)[1],
        on_deleted_line = false,
        single_file_deltaview = false,
    }
end

--- Maps the cursor in a deltaview diff buffer back to a worktree file and line, using the same
--- `delta_diff_data_set` buffer variable deltaview uses to place the cursor when exiting a diff.
---@param bufnr integer
---@return HunkTarget | nil
local get_deltaview_hunk_target = function(bufnr)
    local diff_data_set = vim.b[bufnr].delta_diff_data_set
    local row = vim.api.nvim_win_get_cursor(0)[1]
    for _, diff_data in ipairs(diff_data_set) do
        for _, hunk in ipairs(diff_data.hunks) do
            local prev_new_line_num ---@type integer | nil
            for line_idx, line in ipairs(hunk.lines) do
                if line.formatted_diff_line_num + 1 == row then
                    local lnum = line.new_line_num
                    local on_deleted_line = lnum == nil
                    if on_deleted_line then
                        lnum = prev_new_line_num
                        if lnum == nil then
                            -- deletion leads the hunk: it sits just before the next surviving line
                            for next_idx = line_idx + 1, #hunk.lines do
                                local next_new_line_num = hunk.lines[next_idx].new_line_num
                                if next_new_line_num then
                                    lnum = next_new_line_num - 1
                                    break
                                end
                            end
                        end
                        lnum = lnum or hunk.new_start
                    end

                    -- `:Delta <path>` diffs carry repo-relative paths; `:DeltaView` diffs are built from
                    -- in-memory text, so the source file is only recorded in the buffer name.
                    local path = diff_data.new_path and (vim.b[bufnr].git_root .. "/" .. diff_data.new_path)
                        or vim.api.nvim_buf_get_name(bufnr):match("^deltaview://diff/(.-)    ")
                    if not path or vim.fn.filereadable(path) == 0 then
                        vim.notify("Could not determine the file for this deltaview line", vim.log.levels.WARN)
                        return nil
                    end

                    return {
                        path = path,
                        lnum = lnum,
                        on_deleted_line = on_deleted_line,
                        single_file_deltaview = diff_data.new_path == nil,
                    }
                end
                prev_new_line_num = line.new_line_num or prev_new_line_num
            end
        end
    end

    vim.notify("Cursor is not on a diff line", vim.log.levels.WARN)
    return nil
end

---@param root string
---@param args string[]
---@param opts? vim.SystemOpts
---@return vim.SystemCompleted
local run_git = function(root, args, opts)
    local cmd = vim.list_extend({ "git", "-C", root }, args)
    return vim.system(cmd, vim.tbl_extend("force", { text = true }, opts or {})):wait()
end

--- Parses `git diff -U0` (index -> worktree) for one file.
---@param root string
---@param relpath string
---@return string[] | nil header # the file header lines (`diff --git`, `index`, `---`, `+++`)
---@return UnstagedHunk[] hunks
local get_unstaged_hunks = function(root, relpath)
    local result = run_git(root, { "diff", "--no-ext-diff", "--no-color", "-U0", "--", relpath })
    if result.code ~= 0 then
        vim.notify("git diff failed: " .. result.stderr, vim.log.levels.ERROR)
        return nil, {}
    end

    local header, hunks = {}, {} ---@type string[], UnstagedHunk[]
    for _, line in ipairs(vim.split(result.stdout, "\n", { trimempty = true })) do
        local new_start, new_count = line:match("^@@ %-%d+,?%d* %+(%d+),?(%d*) @@")
        if new_start then
            table.insert(hunks, {
                new_start = tonumber(new_start),
                new_count = new_count == "" and 1 or tonumber(new_count),
                lines = { line },
            })
        elseif #hunks > 0 then
            table.insert(hunks[#hunks].lines, line)
        else
            table.insert(header, line)
        end
    end
    return header, hunks
end

--- Whether an index -> worktree hunk covers the cursor target. A pure deletion (count 0) sits after line
--- `new_start`; in a file buffer it is shown on line `new_start` (or line 1 for a deletion at the top).
---@param hunk UnstagedHunk
---@param target HunkTarget
---@return boolean
local hunk_contains_target = function(hunk, target)
    local last = hunk.new_start + hunk.new_count - 1
    if target.on_deleted_line then
        if hunk.new_count == 0 then return hunk.new_start == target.lnum end
        return hunk.new_start <= target.lnum + 1 and target.lnum + 1 <= last
    end
    if hunk.new_count == 0 then return hunk.new_start == target.lnum or (hunk.new_start == 0 and target.lnum == 1) end
    return hunk.new_start <= target.lnum and target.lnum <= last
end

--- Rebuilds a `:DeltaView` buffer (deltaview has no refresh API) by returning to the source file at
--- the committed hunk and reopening the view against the persisted git base.
---@param target HunkTarget
local rebuild_deltaview = function(target)
    vim.cmd.edit(vim.fn.fnameescape(target.path))
    local lnum = math.min(math.max(target.lnum, 1), vim.api.nvim_buf_line_count(0))
    vim.api.nvim_win_set_cursor(0, { lnum, 0 })
    M.open_deltaview()
end

--- Stages the unstaged (index -> worktree) hunk under the cursor and commits it, or amends HEAD with it.
--- Works in file buffers and deltaview diff buffers. Untracked files are staged whole. Refuses to run
--- when the index already has staged changes, so the commit contains only this hunk.
---@param amend boolean
M.commit_cursor_hunk = function(amend)
    local bufnr = vim.api.nvim_get_current_buf()
    -- deltaview's own `is_deltaview_buffer()` checks a variable it never sets, so detect its diff data instead
    local target
    if vim.b[bufnr].delta_diff_data_set then
        target = get_deltaview_hunk_target(bufnr)
    else
        target = get_buffer_hunk_target(bufnr)
    end
    if not target then return end

    -- dotfiles buffers are often named via symlinks; git needs the real path to compute a repo-relative one
    local realpath = vim.uv.fs_realpath(target.path) or target.path
    local toplevel = run_git(vim.fs.dirname(realpath), { "rev-parse", "--show-toplevel" })
    if toplevel.code ~= 0 then
        vim.notify("Not in a git repository: " .. target.path, vim.log.levels.WARN)
        return
    end
    local root = vim.trim(toplevel.stdout)
    local relpath = realpath:sub(#root + 2)

    if run_git(root, { "diff", "--cached", "--quiet" }).code ~= 0 then
        vim.notify("The index already has staged changes; commit or unstage them first", vim.log.levels.WARN)
        return
    end

    local stage_args ---@type string[]
    local stage_opts ---@type vim.SystemOpts | nil
    if run_git(root, { "ls-files", "--error-unmatch", "--", relpath }).code ~= 0 then
        stage_args = { "add", "--", relpath }
    else
        local header, hunks = get_unstaged_hunks(root, relpath)
        if not header then return end
        local hunk = vim.iter(hunks):find(function(h) return hunk_contains_target(h, target) end)
        if not hunk then
            vim.notify("No unstaged hunk under the cursor", vim.log.levels.WARN)
            return
        end
        stage_args = { "apply", "--cached", "--unidiff-zero", "--whitespace=nowarn", "-" }
        stage_opts = { stdin = table.concat(vim.list_extend(vim.list_extend({}, header), hunk.lines), "\n") .. "\n" }
    end

    ---@param commit_args string[]
    local stage_and_commit = function(commit_args)
        local staged = run_git(root, stage_args, stage_opts)
        if staged.code ~= 0 then
            vim.notify("Failed to stage hunk: " .. staged.stderr, vim.log.levels.ERROR)
            return
        end

        local committed = run_git(root, vim.list_extend({ "commit" }, commit_args))
        if committed.code ~= 0 then
            -- the index matched HEAD before staging, so resetting this path restores it exactly
            run_git(root, { "reset", "-q", "--", relpath })
            vim.notify("Commit failed, hunk unstaged:\n" .. committed.stderr .. committed.stdout, vim.log.levels.ERROR)
            return
        end
        vim.notify(vim.split(committed.stdout, "\n")[1], vim.log.levels.INFO)

        if package.loaded.gitsigns then require("gitsigns").refresh() end
        if target.single_file_deltaview then rebuild_deltaview(target) end
    end

    if amend then
        stage_and_commit({ "--amend", "--no-edit" })
    else
        vim.ui.input({ prompt = "Commit message: " }, function(message)
            if message and vim.trim(message) ~= "" then stage_and_commit({ "-m", message }) end
        end)
    end
end

vim.keymap.set("n", "<leader>hc", function() M.commit_cursor_hunk(false) end, { desc = "Stage and commit hunk" })
vim.keymap.set("n", "<leader>ha", function() M.commit_cursor_hunk(true) end, { desc = "Stage and amend hunk" })

return M
