-- lsp // cmp // luasnip
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

local lspconfig = require('lspconfig')


-- Enable some language servers with the additional completion capabilities offered by nvim-cmp
local servers = { 'clangd', 'pyright', 'tsserver', 'eslint', 'vuels' }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    capabilities = capabilities,
    on_attach = function()
      vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = 0 })
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = 0 })
      vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, { buffer = 0 })
      vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = 0 })
      vim.keymap.set("n", "<leader>dn", vim.diagnostic.goto_next, { buffer = 0 })
      vim.keymap.set("n", "<leader>dp", vim.diagnostic.goto_prev, { buffer = 0 })
    end
  }
end

-- luasnip setup
local luasnip = require 'luasnip'


-- nvim-cmp setup
local cmp = require 'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  } , {
    { name = 'buffer' },
  })  
}

-- Use cmdline & path source for ':'
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})


-- Use buffer source for `/`
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})


-- define diagnostic signs, and highlights. currently configured to only
-- highline line numbers, and not display signs
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, {
    numhl = hl,
    -- text = icon,
    -- texthl = hl,
  })
end


-- configure display of diagnostics and diagnostic floats
vim.diagnostic.config({
  signs = true,
  virtual_text = false, -- { source = true, severity = 'error', spacing = 10, },
  float = {
    wrap = true,
    max_width = 60,
    source = true,
    -- severity = { max = 'warn' }, 
    border = 'double',
    style = 'minimal',
  },
})
