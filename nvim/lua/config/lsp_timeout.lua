local utils = require("config.utils")

local M = {}

local STOP_TIMEOUT_MS = 1000 * 60 * 10

---@type uv.uv_timer_t | nil
local stop_timer = nil

-- Server names stopped by the timer, restarted on focus
---@type table<string, true>
local stopped_servers = {}
local stopped_copilot = false

local cancel_stop_timer = function()
    if not stop_timer then return end
    stop_timer:stop()
    stop_timer:close()
    stop_timer = nil
end

-- copilot.lua owns its client and treats any exit as `:Copilot disable`, so it is
-- stopped and started through its own commands rather than vim.lsp
---@return boolean
local copilot_running = function()
    if not package.loaded["copilot"] then return false end
    local client = require("copilot.client")
    return not client.is_disabled() and client.get() ~= nil
end

---@param names string[]
local stop = function(names)
    for _, client in ipairs(vim.lsp.get_clients()) do
        if vim.tbl_contains(names, client.name) then
            stopped_servers[client.name] = true
            -- Detach before stopping: servers like tailwindcss unregister dynamic
            -- capabilities on shutdown, which makes nvim skip capability cleanup on
            -- exit and later assert on the dead client (e.g. document_color on ColorScheme)
            for bufnr in pairs(client.attached_buffers) do
                vim.lsp.buf_detach_client(bufnr, client.id)
            end
            client:stop()
        end
    end

    if copilot_running() then
        require("copilot.command").disable()
        stopped_copilot = true
    end

    local stopped = vim.tbl_keys(stopped_servers)
    if stopped_copilot then table.insert(stopped, "copilot") end
    if #stopped > 0 then vim.notify("Stopped idle LSPs: " .. table.concat(stopped, ", ")) end
end

local restart = function()
    local names = vim.tbl_keys(stopped_servers)
    if #names > 0 then vim.lsp.enable(names) end

    if stopped_copilot then
        require("copilot.command").enable()
        table.insert(names, "copilot")
    end

    if #names > 0 then vim.notify("Restarted LSPs: " .. table.concat(names, ", ")) end

    stopped_servers = {}
    stopped_copilot = false
end

--- Stop the given servers and copilot after nvim has been unfocused for
--- STOP_TIMEOUT_MS, and restart them when focus returns
---@param names string[] names of servers enabled via vim.lsp.enable
M.setup = function(names)
    local group = utils.augroup("lsp_timeout")

    vim.api.nvim_create_autocmd("FocusLost", {
        desc = "Stop LSPs after nvim has been unfocused for a while",
        group = group,
        callback = function()
            if stop_timer then return end
            stop_timer = vim.uv.new_timer()
            if not stop_timer then
                vim.notify("Failed to create LSP stop timer", vim.log.levels.ERROR)
                return
            end
            stop_timer:start(
                STOP_TIMEOUT_MS,
                0,
                vim.schedule_wrap(function()
                    cancel_stop_timer()
                    stop(names)
                end)
            )
        end,
    })

    vim.api.nvim_create_autocmd("FocusGained", {
        desc = "Cancel the LSP stop timer and restart stopped LSPs",
        group = group,
        callback = function()
            cancel_stop_timer()
            restart()
        end,
    })
end

return M
