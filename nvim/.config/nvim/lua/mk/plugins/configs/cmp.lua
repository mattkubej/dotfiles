local cmp = require('cmp')

cmp.setup({
  mapping = {
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'buffer' },
  }
})

require('nvim-autopairs.completion.cmp').setup({
  map_cr = true,
  map_complete = true,
  auto_select = true,
  insert = false,
  map_char = {
    all = '(',
    tex = '{'
  }
})
