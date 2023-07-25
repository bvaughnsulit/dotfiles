local utils = require('config.utils')

return {
  {
    'LazyVim/LazyVim',
    lazy = false,
    config = function()
      local lazyvim_utils = require('lazyvim.util')
      local config_dir = '/Users/vaughn/dotfiles/lazygit/'
      local base_config = config_dir .. 'lazygit.yml'
      local light_config = base_config .. ',' .. config_dir .. 'light.yml'
      utils.create_cmd_and_map(
        'G',
        '<leader>gg',
        function()
          lazyvim_utils.float_term({
            'lazygit',
            '-ucf',
            utils.is_system_dark_mode() and base_config or light_config,
          }, {
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
