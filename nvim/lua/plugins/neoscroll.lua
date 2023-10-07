local utils = require('config.utils')

return {
  'karb94/neoscroll.nvim',
  enabled = true,
  dev = false,
  event = 'VeryLazy',
  config = function()
    local neoscroll = require('neoscroll')
    neoscroll.setup({
      mappings = {},
      hide_cursor = false, -- Hide cursor while scrolling
      stop_eof = false, -- Stop at <EOF> when scrolling downwards
      respect_scrolloff = false, -- Stop scrolling when the cursor reaches the scrolloff margin of the file
      cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
      easing_function = 'sine', -- Default easing function
      pre_hook = nil, -- Function to run before the scrolling animation starts
      post_hook = nil, -- Function to run after the scrolling animation ends
      performance_mode = false, -- Disable "Performance Mode" on all buffers.
    })

    utils.create_cmd_and_map(
      nil,
      '<c-u>',
      function() neoscroll.scroll(-vim.wo.scroll, true, 75) end
    )

    utils.create_cmd_and_map(
      nil,
      '<c-d>',
      function() neoscroll.scroll(vim.wo.scroll, true, 75) end
    )
  end,
}
