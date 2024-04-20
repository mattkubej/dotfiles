return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'onsails/lspkind.nvim',
      'nvimtools/none-ls.nvim',
      'jay-babu/mason-null-ls.nvim',
      {
        'j-hui/fidget.nvim',
        opts = {
          integration = {
            ["nvim-tree"] = {
              enable = false,
            },
          },
        }
      },
      { 'folke/neodev.nvim', opts = {} },
      {
        "pmizio/typescript-tools.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
          local nvim_lsp = require('lspconfig')
          require('typescript-tools').setup({
            single_file_support = os.getenv("SPIN") ~= nil,
            settings = {
              separate_diagnostic_server = os.getenv("SPIN") == nil,
              tsserver_max_memory = 10240,
              root_dir = nvim_lsp.util.root_pattern("package.json"),
            },
            on_attach = function(client)
              client.server_capabilities.documentFormattingProvider = false
              client.server_capabilities.documentFormattingRangeProvider = false
            end,
          })
        end,
      }
    },
    config = function()
      local lsp = require('lspconfig')

      vim.api.nvim_create_autocmd('LspAttach', {
        desc = 'LSP actions',
        callback = function(event)
          local nmap = function(keys, func, desc)
            if desc then
              desc = 'LSP: ' .. desc
            end

            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = desc })
          end

          nmap('<leader>d', vim.diagnostic.open_float, 'Open diagnostic float')
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

      require("lspconfig.ui.windows").default_options.border = "rounded"

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

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
          'sorbet',
          'ruby_lsp',
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
    end
  },
}
