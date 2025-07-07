local M = {}

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

    if type(command) == "string" and #command > 0 then
        vim.api.nvim_create_user_command(command, fn, { desc = desc_with_fallback })
    elseif type(command) == "table" then
        if command.name then
            if not command.opts.desc then command.opts.desc = desc_with_fallback end
            vim.api.nvim_create_user_command(command.name, fn, command.opts)
        end
    end

    if type(mapping) == "string" and #mapping > 0 then
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
    local result = vim.system({
        "git",
        "config",
        "--get",
        "remote.origin.url",
    }, { text = true }):wait()

    if result.code ~= 0 or result.stdout == "" then
        vim.notify("Error getting git remote URL")
        return
    end
    if result.stdout then return result.stdout:sub(1, -6) end
end

---@return string | nil
M.get_gh_file_url = function()
    local path = vim.fn.expand("%:.")
    local hash = M.get_merge_base_hash()
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

M.get_dotfiles_root = function()
    local result = vim.system({
        "readlink",
        "-f",
        vim.fn.stdpath("config"),
    }, { text = true }):wait()

    if result.code ~= 0 then
        vim.notify("Error following nvim config symlink")
        return
    end
    return Snacks.git.get_root(result.stdout:sub(1, -2))
end

M.jump_from_term_buffer = function()
    local mode = vim.api.nvim_get_mode().mode --[[@as "n"|"t"|string]]
    local cmd = ""
    if mode == "n" or mode == "nt" then
        cmd = "<c-o>"
    elseif mode == "t" then
        cmd = "<c-\\><c-n><c-o>"
    else
        return
    end
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(cmd, true, true, true), "", false)
end

---@class TerminalOpts
---@field q_to_go_back? ("t"|"n")[] | nil
---@field auto_insert? boolean
---@field win_config? vim.api.keyset.win_config
---@field job_opts? table # options to pass to `vim.fn.jobstart`
---@see vim.fn.jobstart
---@see vim.api.nvim_open_win

---@param cmd string|string[]
---@param name string
---@param opts? TerminalOpts
M.toggle_persistent_terminal = function(cmd, name, opts)
    opts = opts or {}
    local buffer_name = "terminal://" .. name
    local job_opts_merged = vim.tbl_deep_extend("force", {
        term = true,
        stdout_buffered = true,
    }, opts.job_opts or {})

    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        -- Check if the buffer already exists
        if vim.api.nvim_buf_get_name(buf):find(buffer_name) then
            -- If the buffer exists, check if it's already open in a window
            for _, window in ipairs(vim.api.nvim_list_wins()) do
                -- If already open in a window, just switch to it and update the config
                if vim.api.nvim_win_get_buf(window) == buf and opts.win_config then
                    vim.api.nvim_win_set_config(window, opts.win_config)
                    vim.api.nvim_set_current_win(window)
                    return
                end
            end

            -- Otherwise, open the buffer
            if opts.win_config then
                vim.api.nvim_open_win(buf, true, opts.win_config)
            else
                vim.api.nvim_win_set_buf(0, buf)
            end
            return
        end
    end

    -- If the buffer does not exist, create and open it
    local buf = vim.api.nvim_create_buf(true, false)

    if opts.win_config then
        vim.api.nvim_open_win(buf, true, opts.win_config)
    else
        vim.api.nvim_win_set_buf(0, buf)
    end
    vim.fn.jobstart(cmd, job_opts_merged)
    vim.api.nvim_buf_set_name(buf, buffer_name)

    -- set the buffer options
    if opts.q_to_go_back then
        vim.keymap.set(opts.q_to_go_back, "q", function()
            local win = vim.api.nvim_win_get_config(0)
            local is_closeable = win.relative ~= ""
            if not is_closeable then
                -- check if the window is full screen
                local ui_lines = (vim.o.tabline ~= "" and 1 or 0) + (vim.o.laststatus ~= 0 and 1 or 0) + vim.o.cmdheight
                local full_width = vim.o.columns == win.width
                local full_height = vim.o.lines - ui_lines == win.height
                is_closeable = not (full_width and full_height)
            end
            if is_closeable then
                vim.api.nvim_win_close(0, false)
            else
                M.jump_from_term_buffer()
            end
        end, {
            buffer = buf,
            desc = "Hide buffer",
        })
    end

    if opts.auto_insert then
        vim.api.nvim_create_autocmd("BufEnter", {
            buffer = buf,
            group = M.augroup(name .. "_terminal_enter"),
            callback = function()
                vim.schedule(function()
                    vim.api.nvim_win_set_cursor(0, { 1, 0 })
                    vim.cmd.startinsert()
                end)
            end,
        })
        vim.cmd.startinsert()
    end
end

M.debug_info = function(...)
    local wins = vim.deepcopy(vim.fn.getwininfo(), true)
    local info = {}

    for i, win in ipairs(wins) do
        local buf_info = vim.deepcopy(vim.fn.getbufinfo(win.bufnr)[1], true)
        local filetype = vim.api.nvim_get_option_value("filetype", { buf = win.bufnr })

        if filetype ~= "dap-repl" and not buf_info.name:find("dap-eval://", 1, true) then
            local filename = M.get_path_tail(buf_info.name)
            local title = string.len(filename) > 0 and filename or filetype

            local key = "[" .. win.winnr .. ":" .. win.bufnr .. "] " .. title

            info[key] = {
                win_info = win,
                buf_info = buf_info,
                buf_name = buf_info.name,
                filetype = filetype,
            }
        end
    end
    return info
end
_G.debug_info = M.debug_info

return M
