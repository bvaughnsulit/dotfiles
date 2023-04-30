local M = {}

M.test_function = function(arg)
  require('notify').notify(arg or 'TESTING', 'ERROR', {})
end


---@class User_Command
---@field name string
---@field opts table

---@class Mapping
---@field mode table|string
---@field lhs string
---@field opts table

---@param command? string|User_Command # Name of command as a string, or a table containing name and opts.
---@param mapping? string|Mapping # Normal mode mapping as a string, or a table containing mode, lhs, and opts.
---@param fn fun()
---@param desc? string
M.create_cmd_and_map = function(command, mapping, fn, desc)
  local desc_with_fallback = desc
  if not desc_with_fallback then
    if command and command.name then
      desc_with_fallback = command.name
    elseif type(command) == 'string' then
      desc_with_fallback = command
    else
      desc_with_fallback = ''
    end
  end

  if type(command) == 'string' then
    vim.api.nvim_create_user_command(command, fn, { desc = desc_with_fallback })
  elseif type(command) == 'table' then
    if command.name then
      if not command.opts.desc then command.opts.desc = desc_with_fallback end
      vim.api.nvim_create_user_command(command.name, fn, command.opts)
    end
  end

  if type(mapping) == 'string' then
    vim.keymap.set('n', mapping, fn, { desc = desc_with_fallback })
  elseif type(mapping) == 'table' then
    if mapping.lhs then
      local opts = vim.tbl_deep_extend('force', {
        remap = false,
        silent = true,
        desc = desc_with_fallback,
      }, mapping.opts or {})
      vim.keymap.set(mapping.mode or 'n', mapping.lhs, fn, opts)
    end
  end
end

-- libuv stuff
local timers = {}

M.debounce = function(fn, ms)
  local timer = vim.loop.new_timer()
  -- save timer to table so that it can be closed later
  table.insert(timers, timer)
  return function(...)
    local args = { ... }
    if timer then
      timer:start(ms, 0, vim.schedule_wrap(function() fn(unpack(args)) end))
    end
  end
end

vim.api.nvim_create_autocmd('VimLeavePre', {
  callback = function()
    for _, timer in pairs(timers) do
      if timer and not timer:is_closing() then timer:close() end
    end
  end,
})

return M
