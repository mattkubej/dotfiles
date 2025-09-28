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

          nmap('<leader>d', vim.diagnostic.open_float, 'Open diagnostic float')
          nmap('[d', vim.diagnostic.goto_prev, 'Go to previous diagnostic')
          nmap(']d', vim.diagnostic.goto_next, 'Go to next diagnostic')

          nmap('K', vim.lsp.buf.hover, 'Hover documentation')
          nmap('gd', vim.lsp.buf.definition, 'Go to definition')
          nmap('gD', vim.lsp.buf.declaration, 'Go to declaration')
          nmap('gi', vim.lsp.buf.implementation, 'Go to implementation')
          nmap('go', vim.lsp.buf.type_definition, 'Go to type definition')
          nmap('gr', require('fzf-lua').lsp_references, 'Go to references')
          nmap('gs', vim.lsp.buf.signature_help, 'Signature documentation')

          nmap('<leader>rn', vim.lsp.buf.rename, 'Rename')
          nmap('<leader>ca', vim.lsp.buf.code_action, 'Code action')
          nmap('<leader>f', function()
            require('conform').format({ async = true, lsp_fallback = true })
          end, 'Format current buffer')
        end
      })

      vim.diagnostic.config({
        virtual_text = true,
      })

      vim.diagnostic.config({
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
                }
              }
            })
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
              'tsconfig.base.json',
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
