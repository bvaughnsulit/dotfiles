local debounce = require('config.utils').debounce

return {
  'akinsho/bufferline.nvim',
  event = 'VeryLazy',
  version = 'v3.*',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require('bufferline').setup({
      options = {
        enforce_regular_tabs = false,
        modified_icon = '*',
        show_tab_indicators = true,
        diagnostics = false,
        show_close_icon = false,
        show_buffer_close_icons = false,
        max_name_length = 26,
        tab_size = 20,
        persist_buffer_sort = true,
      },
    })

    local run_custom_sort = debounce(function()
      -- todo: move to pos 1 instead of sort
      -- TODO: check if there are buffers to sort (e.g. > 1)
      require('bufferline').sort_buffers_by(
        function(a, b)
          return vim.fn.getbufinfo(a.id)[1].lastused > vim.fn.getbufinfo(b.id)[1].lastused
        end
      )
    end, 2000)

    -- local bufferline_sort = vim.api.nvim_create_augroup('BufferlineSort', { clear = true })
    -- vim.api.nvim_create_autocmd('BufEnter', {
    --   callback = run_custom_sort,
    --   group = bufferline_sort,
    -- })

    vim.keymap.set({ 'n', 'v' }, ']b', '<cmd>BufferLineCycleNext<cr>', {})
    vim.keymap.set({ 'n', 'v' }, '<a-]>', '<cmd>BufferLineCycleNext<cr>', {})
    vim.keymap.set({ 'n', 'v' }, '[b', '<cmd>BufferLineCyclePrev<cr>', {})
    vim.keymap.set({ 'n', 'v' }, '<a-[>', '<cmd>BufferLineCyclePrev<cr>', {})
    vim.keymap.set({ 'n', 'v' }, '<leader>bp', '<cmd>BufferLinePick<cr>', {})
  end,
}
