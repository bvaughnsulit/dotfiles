local git_lazy = require('lazy.manage.git')
local M = {}

M.lazyvim = require('lazyvim.util')

M.test_function = function(arg) require('notify').notify(arg or 'TESTING', 'ERROR', {}) end

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

---@alias branch 'main' | 'master'
---@return branch | nil
M.get_default_branch_name = function()
  local git_config = git_lazy.get_config('.')
  if git_config['branch.main.remote'] then
    return 'main'
  elseif git_config['branch.master.remote'] then
    return 'master'
  end
end

---@return string | nil
M.get_gh_repo_url = function()
  local git_config = git_lazy.get_config('.')
  local repo_url = git_config['remote.origin.url']
  if repo_url then return repo_url:sub(1, -5) end
end

---@return string | nil
M.get_gh_file_url = function()
  local path = vim.fn.expand('%:.')
  local branch = M.get_default_branch_name()
  local repo_url = M.get_gh_repo_url()
  if repo_url then return repo_url .. '/blob/' .. branch .. '/' .. path end
end

---@return nil
M.copy_gh_file_url = function()
  local url = M.get_gh_file_url()
  vim.fn.setreg('+', url)
  vim.notify('Copied to clipboard: ' .. url)
end

M.open_file_in_gh = function()
  local url = M.get_gh_file_url()
  vim.cmd('silent !open ' .. url)
end

M.open_repo_in_gh = function()
  local url = M.get_gh_repo_url()
  vim.cmd('silent !open ' .. url)
end

M.is_system_dark_mode = function()
  if
    string.find(
      vim.fn.system('defaults read -globalDomain AppleInterfaceStyle 2>/dev/null'),
      'Dark'
    )
  then
    return true
  else
    return false
  end
end

return M
