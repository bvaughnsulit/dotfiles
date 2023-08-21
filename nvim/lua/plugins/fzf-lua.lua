return {
  {
    'ibhagwan/fzf-lua',
    event = 'VeryLazy',
    config = function()
      require('fzf-lua').setup({
        winopts = {
          preview = { delay = 20 },
        },
      })
    end,
  },
}
