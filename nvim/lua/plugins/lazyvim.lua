local utils = require('config.utils')

return {
  {
    'LazyVim/LazyVim',
    lazy = false,
    config = function()
      local lazyvim_utils = require('lazyvim.util')
      utils.create_cmd_and_map(
        'G',
        '<leader>gg',
        function()
          lazyvim_utils.float_term('lazygit', {
            cwd = lazyvim_utils.get_root(),
            esc_esc = false,
            ctrl_hjkl = false,
            size = {
              width = 0.95,
              height = 0.95,
            },
          })
        end,
        'Lazygit (root dir)'
      )
    end,
  },
}
