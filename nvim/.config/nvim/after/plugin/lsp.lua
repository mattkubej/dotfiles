local ok, lsp = pcall(require, 'lspconfig')
if not ok then return end

vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    local nmap = function(keys, func, desc)
      if desc then
        desc = 'LSP: ' .. desc
      end

      vim.keymap.set('n', keys, func, { buffer = event.buf, desc = desc })
    end

    nmap('<space>e', vim.diagnostic.open_float, 'Open diagnostic float')
    nmap('[d', vim.diagnostic.goto_prev, 'Go to previous diagnostic')
    nmap(']d', vim.diagnostic.goto_next, 'Go to next diagnostic')

    nmap('K', vim.lsp.buf.hover, 'Hover documentation')
    nmap('gd', vim.lsp.buf.definition, 'Go to definition')
    nmap('gD', vim.lsp.buf.declaration, 'Go to declaration')
    nmap('gi', vim.lsp.buf.implementation, 'Go to implementation')
    nmap('go', vim.lsp.buf.type_definition, 'Go to type definition')
    nmap('gr', require('telescope.builtin').lsp_references, 'Go to references')
    nmap('gs', vim.lsp.buf.signature_help, 'Signature documentation')

    nmap('<leader>rn', vim.lsp.buf.rename, 'Rename')
    nmap('<leader>ca', vim.lsp.buf.code_action, 'Code action')
    nmap('<leader>f', function()
      vim.lsp.buf.format({ timeout_ms = 10000 })
    end, 'Format current buffer')
  end
})

vim.diagnostic.config({
  virtual_text = true,
})

vim.diagnostic.config({
  float = { border = 'rounded' },
})

vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
  vim.lsp.handlers.hover,
  { border = 'rounded' }
)

vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
  vim.lsp.handlers.signature_help,
  { border = 'rounded' }
)

local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

local default_setup = function(server)
  lsp[server].setup({
    capabilities = lsp_capabilities,
  })
end

require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = {
    'lua_ls',
    'rust_analyzer',
    'graphql',
    'html',
    'pylsp',
    'solargraph',
    'sorbet',
    'ruby_ls',
    'rubocop',
    'eslint',
    'jsonls',
    'stylelint_lsp',
  },
  handlers = {
    default_setup,
    lua_ls = function()
      lsp.lua_ls.setup({
        capabilities = lsp_capabilities,
        settings = {
          Lua = {
            diagnostics = {
              globals = { 'vim' }
            }
          }
        }
      })
    end,
  },
})
require("mason-null-ls").setup({
  ensure_installed = {},
  automatic_installation = false,
  handlers = {},
})
local null_ls = require('null-ls')
null_ls.setup({
  sources = {
    null_ls.builtins.formatting.prettier.with({
      prefer_local = 'node_modules/.bin',
    }),
  }
})

local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local lspkind = require('lspkind')

cmp.setup({
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'buffer' },
    { name = 'path' },
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
    ['<CR>'] = cmp.mapping.confirm({ select = false }),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<Tab>'] = nil,
    ['<S-Tab>'] = nil,
  }),
  preselect = cmp.PreselectMode.None,
  completion = {
    completeopt = 'menu,menuone,noinsert,noselect',
  },
  formatting = {
    format = lspkind.cmp_format({
      mode = 'symbol_text',
      menu = ({
        buffer = "[Buffer]",
        nvim_lsp = "[LSP]",
        luasnip = "[LuaSnip]",
        nvim_lua = "[Lua]",
      })
    })
  }
})

cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    {
      name = 'cmdline',
      option = {
        ignore_cmds = { 'Man', '!' }
      }
    }
  })
})
