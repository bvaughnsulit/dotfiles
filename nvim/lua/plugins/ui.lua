return {
  {
    'rcarriga/nvim-notify',
    init = function()
      local notify = require 'notify'
      notify.setup {
        timeout = 2000,
        stages = 'slide',
        max_height = function()
          return math.floor(vim.o.lines * 0.75)
        end,
        max_width = function()
          return math.floor(vim.o.columns * 0.75)
        end,
      }
      vim.notify = notify
    end,
  },
}
