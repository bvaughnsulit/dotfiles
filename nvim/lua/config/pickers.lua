local M = {}

local pickers = {}
M.register_picker = function(picker_name, functions) pickers[picker_name] = functions end

local picker = 'telescope'
M.change_picker = function(new_picker) picker = new_picker end

local call = function(fn_name, ...)
  if pickers[picker] and pickers[picker][fn_name] then
    pickers[picker][fn_name](...)
  else
    logger('Not found: ' .. picker .. ' ' .. fn_name)
  end
end

M.maps = {
  find_files = { '<C-p>', 'Find Files' },
  buffers = { '<C-b>', 'Buffers' },
  live_grep = { '<C-f>', 'Live Grep' },
  lsp_definitions = { 'gd', 'Go to Definition' },
  lsp_references = { 'gr', 'Go to References' },
  lsp_type_definitions = { 'gt', 'Go to Type Definition' },
  keymaps = { '<leader>km', 'Keymaps' },
  help_tags = { '<leader>?', 'Help Tags' },
  commands = { '<leader><leader>', 'Commands' },
  buffer_fuzzy = { '<leader>/f', 'Current Buffer Fuzzy Search' },
}

for name, opts in pairs(M.maps) do
  vim.keymap.set('n', opts[1], function() call(name) end, {
    desc = opts[2],
  })
end

vim.api.nvim_create_user_command('PickerTelescope', function() M.change_picker('telescope') end, {})
vim.api.nvim_create_user_command('PickerSnacks', function() M.change_picker('snacks') end, {})

return M
