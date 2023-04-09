local M = {}

M.map = function(mode, lhs, rhs, opts)
  opts =
    vim.tbl_deep_extend('force', { noremap = true, silent = true }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

M.create_cmd = function(name, command, opts)
  opts = opts or {}
  vim.api.nvim_create_user_command(name, command, opts)
end

M.gh_browse = function() vim.cmd('!gh browse') end

M.save_and_source = function()
  vim.cmd('w')
  vim.cmd('so %')
end

M.toggle_rel_num = function()
  vim.opt.relativenumber = not vim.opt.relativenumber:get()
end

M.toggle_wrap = function() vim.opt.wrap = not vim.opt.wrap:get() end
M.disable_diagnostics_in_buffer = function() vim.diagnostic.disable(0) end
M.enable_diagnostics_in_buffer = function() vim.diagnostic.enable(0) end

M.delete_all_bufs = function() vim.cmd('%bd') end

-- libuv stuff
local timers = {}

M.debounce = function(fn, ms)
  local timer = vim.loop.new_timer()
  -- save timer to table so that it can be closed later
  table.insert(timers, timer)
  return function(...)
    local args = { ... }
    timer:start(ms, 0, vim.schedule_wrap(function() fn(unpack(args)) end))
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
