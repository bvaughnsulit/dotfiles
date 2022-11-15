require('bufferline').setup {
  options = {
    enforce_regular_tabs = false,
    modified_icon = '*',
    show_tab_indicators = true,
    diagnostics = false,
    show_close_icon = false,
    show_buffer_close_icons = false,
    sort_by = function(a,b)
      return vim.fn.getbufinfo(a.id)[1].lastused > vim.fn.getbufinfo(b.id)[1].lastused
    end,
    max_name_length = 26,

    -- custom_filter = function(buf_number, buf_numbers)
    --     print(vim.inspect(buf_numbers)
    --     if buf_numbers[1] ~= buf_number then
    --         return true
    --     end
    -- end,
  }
}

vim.keymap.set({'n','v'}, ']b', '<cmd>BufferLineCycleNext<cr>', {})
vim.keymap.set({'n','v'}, '<a-]>', '<cmd>BufferLineCycleNext<cr>', {})
vim.keymap.set({'n','v'}, '[b', '<cmd>BufferLineCyclePrev<cr>', {})
vim.keymap.set({'n','v'}, '<a-[>', '<cmd>BufferLineCyclePrev<cr>', {})
vim.keymap.set({'n','v'}, '<leader>bp', '<cmd>BufferLinePick<cr>', {})


-- numbers = "none" | "ordinal" | "buffer_id" | "both" | function({ ordinal, id, lower, raise }): string,
-- close_command = "bdelete! %d",       -- can be a string | function, see "Mouse actions"
-- indicator = {
--     icon = '▎', -- this should be omitted if indicator style is not 'icon'
--     style = 'icon' | 'underline' | 'none',
-- },
-- max_name_length = 18,
-- max_prefix_length = 15, -- prefix used when a buffer is de-duplicated
-- truncate_names = true -- whether or not tab names should be truncated
-- tab_size = 18,
--
-- offsets = {
--     {
--         filetype = "NvimTree",
--         text = "File Explorer" | function ,
--         text_align = "left" | "center" | "right"
--         separator = true
--     }
-- },
-- show_duplicate_prefix = true | false, -- whether to show duplicate buffer prefix
-- persist_buffer_sort = true, -- whether or not custom sorted buffers should persist
-- -- can also be a table containing 2 custom separators
-- -- [focused and unfocused]. eg: { '|', '|' }
-- always_show_bufferline = true | false,
-- hover = {
--     enabled = true,
--     delay = 200,
--     reveal = {'close'}
-- },
