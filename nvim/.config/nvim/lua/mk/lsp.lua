vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    local nmap = function(keys, func, desc)
      if desc then
        desc = 'LSP: ' .. desc
      end
      vim.keymap.set('n', keys, func, { buffer = event.buf, desc = desc })
    end

    -- Diagnostics
    nmap('<leader>D', vim.diagnostic.open_float, 'Open diagnostic float')
    nmap('[d', function() vim.diagnostic.jump({ count = -1 }) end, 'Previous diagnostic')
    nmap(']d', function() vim.diagnostic.jump({ count = 1 }) end, 'Next diagnostic')
    nmap('[e', function()
      vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })
    end, 'Previous error')
    nmap(']e', function()
      vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR })
    end, 'Next error')

    -- Navigation
    nmap('K', vim.lsp.buf.hover, 'Hover documentation')
    nmap('gd', vim.lsp.buf.definition, 'Go to definition')
    nmap('gD', vim.lsp.buf.declaration, 'Go to declaration')
    nmap('gi', vim.lsp.buf.implementation, 'Go to implementation')
    nmap('go', vim.lsp.buf.type_definition, 'Go to type definition')
    nmap('gr', function() require('fzf-lua').lsp_references() end, 'Go to references')
    nmap('gs', vim.lsp.buf.signature_help, 'Signature documentation')

    -- Refactoring
    nmap('<leader>rn', vim.lsp.buf.rename, 'Rename symbol')
    nmap('<leader>ca', vim.lsp.buf.code_action, 'Code action')
    nmap('<leader>f', function()
      require('conform').format({ async = true, lsp_format = 'fallback' })
    end, 'Format buffer')

    -- Inlay hints toggle
    nmap('<leader>ih', function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
    end, 'Toggle inlay hints')
  end
})

-- Disable inlay hints by default (toggle with <leader>ih)
vim.lsp.inlay_hint.enable(false)

vim.diagnostic.config({
  virtual_text = true,
  severity_sort = true,
  float = {
    border = 'rounded',
    source = true,
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '●',
      [vim.diagnostic.severity.WARN]  = '●',
      [vim.diagnostic.severity.INFO]  = '●',
      [vim.diagnostic.severity.HINT]  = '●',
    },
  },
})

vim.o.winborder = 'rounded'

vim.lsp.enable({
  'lua_ls',
  'rust_analyzer',
  'graphql',
  'html',
  'pylsp',
  'sorbet',
  'ruby_lsp',
  'eslint',
  'jsonls',
  'stylelint_lsp',
  'tsgo',
})
