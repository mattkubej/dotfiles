vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.shortmess:append "c"
vim.g.completion_matching_strategy_list = {'exact', 'substring', 'fuzzy'}

local cmp = require('cmp')

local lspkind = require('lspkind')
lspkind.init()

require('mk.plugins.configs.cmp.luasnip')

cmp.setup({
  mapping = {
    ['<c-d>'] = cmp.mapping.scroll_docs(-4),
    ['<c-f>'] = cmp.mapping.scroll_docs(4),
    ['<c-space>'] = cmp.mapping.complete(),
    ['<c-e>'] = cmp.mapping.close(),
    ['<c-y>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = true
    }),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = false,
    }),
  },
  sources = {
    { name = 'nvim_lua' },
    { name = 'nvim_lsp' },
    { name = 'path' },
    { name = 'luasnip' },
    { name = 'buffer', keyword_length = 5 },
  },
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  formatting = {
    format = lspkind.cmp_format {
      with_text = true,
      menu = {
        buffer = "[buf]",
        nvim_lsp = "[lsp]",
        nvim_lua = "[api]",
        path = "[path]",
        luasnip = "[snip]",
      },
    },
  },
  experimental = {
    native_menu = false,
  },
})
