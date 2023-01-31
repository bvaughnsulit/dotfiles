return {
  'akinsho/bufferline.nvim',
  version = 'v3.*',
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function()
    require('bufferline').setup {
      options = {
        enforce_regular_tabs = false,
        modified_icon = '*',
        show_tab_indicators = true,
        diagnostics = false,
        show_close_icon = false,
        show_buffer_close_icons = false,
        sort_by = function(a, b)
          return vim.fn.getbufinfo(a.id)[1].lastused > vim.fn.getbufinfo(b.id)[1].lastused
        end,
        max_name_length = 26,
        tab_size = 22,
        persist_buffer_sort = false,
      },
    }

    vim.keymap.set({ 'n', 'v' }, ']b', '<cmd>BufferLineCycleNext<cr>', {})
    vim.keymap.set({ 'n', 'v' }, '<a-]>', '<cmd>BufferLineCycleNext<cr>', {})
    vim.keymap.set({ 'n', 'v' }, '[b', '<cmd>BufferLineCyclePrev<cr>', {})
    vim.keymap.set({ 'n', 'v' }, '<a-[>', '<cmd>BufferLineCyclePrev<cr>', {})
    vim.keymap.set({ 'n', 'v' }, '<leader>bp', '<cmd>BufferLinePick<cr>', {})
  end,
  event = 'VeryLazy',
}
