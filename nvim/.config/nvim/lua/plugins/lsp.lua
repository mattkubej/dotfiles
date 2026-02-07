return {
  {
    'williamboman/mason.nvim',
    opts = {}
  },

  {
    'stevearc/conform.nvim',
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require('conform').setup({
        formatters_by_ft = {
          javascript = { "prettier" },
          typescript = { "prettier" },
          javascriptreact = { "prettier" },
          typescriptreact = { "prettier" },
          json = { "prettier" },
          jsonc = { "prettier" },
          html = { "prettier" },
          css = { "prettier" },
          scss = { "prettier" },
          markdown = { "prettier" },
          yaml = { "prettier" },
          graphql = { "prettier" },
        },
        format_on_save = function(bufnr)
          -- Disable with a global or buffer-local variable
          if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
            return
          end
          return { timeout_ms = 500, lsp_fallback = true }
        end,
      })

      -- Commands to toggle format on save
      vim.api.nvim_create_user_command("FormatDisable", function(args)
        if args.bang then
          vim.g.disable_autoformat = true
        else
          vim.b.disable_autoformat = true
        end
      end, {
        desc = "Disable autoformat-on-save",
        bang = true,
      })

      vim.api.nvim_create_user_command("FormatEnable", function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
      end, {
        desc = "Re-enable autoformat-on-save",
      })
    end
  },

  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason-lspconfig.nvim',
      'onsails/lspkind.nvim',
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
      { 'folke/lazydev.nvim', ft = 'lua', opts = {} },
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

          -- Diagnostics
          nmap('<leader>D', vim.diagnostic.open_float, 'Open diagnostic float')
          nmap('[d', vim.diagnostic.goto_prev, 'Previous diagnostic')
          nmap(']d', vim.diagnostic.goto_next, 'Next diagnostic')
          nmap('[e', function()
            vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
          end, 'Previous error')
          nmap(']e', function()
            vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
          end, 'Next error')

          -- Navigation
          nmap('K', vim.lsp.buf.hover, 'Hover documentation')
          nmap('gd', vim.lsp.buf.definition, 'Go to definition')
          nmap('gD', vim.lsp.buf.declaration, 'Go to declaration')
          nmap('gi', vim.lsp.buf.implementation, 'Go to implementation')
          nmap('go', vim.lsp.buf.type_definition, 'Go to type definition')
          nmap('gr', require('fzf-lua').lsp_references, 'Go to references')
          nmap('gs', vim.lsp.buf.signature_help, 'Signature documentation')

          -- Refactoring
          nmap('<leader>rn', vim.lsp.buf.rename, 'Rename symbol')
          nmap('<leader>ca', vim.lsp.buf.code_action, 'Code action')
          nmap('<leader>f', function()
            require('conform').format({ async = true, lsp_fallback = true })
          end, 'Format buffer')

          -- Inlay hints toggle (if supported)
          if vim.lsp.inlay_hint then
            nmap('<leader>ih', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
            end, 'Toggle inlay hints')
            -- Enable inlay hints by default
            vim.lsp.inlay_hint.enable(false)
          end

        end
      })

      vim.diagnostic.config({
        virtual_text = true,
        float = { border = 'rounded' },
      })

      vim.o.winborder = 'rounded'


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
                  },
                  workspace = {
                    checkThirdParty = false,
                  },
                  telemetry = {
                    enable = false,
                  },
                  hint = {
                    enable = true,
                  },
                }
              }
            })
          end,
          rust_analyzer = function()
            lsp.rust_analyzer.setup({
              capabilities = lsp_capabilities,
              settings = {
                ['rust-analyzer'] = {
                  inlayHints = {
                    bindingModeHints = { enable = true },
                    chainingHints = { enable = true },
                    closingBraceHints = { enable = true },
                    closureReturnTypeHints = { enable = 'always' },
                    lifetimeElisionHints = { enable = 'always' },
                    parameterHints = { enable = true },
                    typeHints = { enable = true },
                  },
                },
              },
            })
          end,
          vtsls = function()
            -- disabled in favor of tsgo
          end,
          ts_ls = function()
            -- disabled in favor of tsgo
          end,
          tsserver = function()
            -- disabled in favor of tsgo
          end,
        },
      })

      -- Setup tsgo as custom server (not available in Mason)
      local configs = require('lspconfig.configs')
      if not configs.tsgo then
        configs.tsgo = {
          default_config = {
            cmd = { 'tsgo', '--lsp', '--stdio' },
            filetypes = {
              'javascript',
              'javascriptreact',
              'javascript.jsx',
              'typescript',
              'typescriptreact',
              'typescript.tsx',
            },
            root_dir = lsp.util.root_pattern(
              'tsconfig.json',
              'jsconfig.json',
              'package.json',
              '.git'
            ),
            single_file_support = true,
          },
        }
      end

      lsp.tsgo.setup({
        capabilities = lsp_capabilities,
      })
    end
  },
}
