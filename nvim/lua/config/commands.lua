local utils = require('config.utils')
local cmd = utils.create_cmd

cmd('Gho', utils.gh_browse)
cmd('RelativeNumbersToggle', utils.toggle_rel_num)
cmd('BDeleteAll', utils.delete_all_bufs)
cmd('SetIndent2', function() utils.set_indent(2) end)
cmd('SetIndent4', function() utils.set_indent(4) end)
cmd('RelativePathToClipboard', function() vim.cmd("let @* = expand('%:.')") end)
