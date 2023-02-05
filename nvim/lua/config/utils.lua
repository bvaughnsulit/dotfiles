local M = {}

M.map = function(mode, lhs, rhs, opts)
  opts = vim.tbl_deep_extend('force', { noremap = true, silent = true }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- libuv stuff
local timers = {}

M.debounce = function(fn, ms)
  local timer = vim.loop.new_timer()
  -- save timer to table so that it can be closed later
  table.insert(timers, timer)
  return function(...)
    local args = { ... }
    timer:start(ms, 0, vim.schedule_wrap(function ()
     fn(unpack(args))
    end))
  end
end

vim.api.nvim_create_autocmd('VimLeavePre', {
  callback = function()
    for _, timer in pairs(timers) do
      if timer and not timer:is_closing() then
        timer:close()
      end
    end
  end,

})

return M
