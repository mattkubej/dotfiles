return {
  {
    'williamboman/mason.nvim',
    opts = {},
  },

  {
    'stevearc/conform.nvim',
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local function js_formatter(bufnr)
        if vim.fs.root(bufnr, { ".oxfmtrc.json", ".oxfmtrc.jsonc" }) then
          return { "oxfmt" }
        end

        return { "prettier" }
      end

      require('conform').setup({
        formatters_by_ft = {
          javascript = js_formatter,
          typescript = js_formatter,
          javascriptreact = js_formatter,
          typescriptreact = js_formatter,
          json = { "prettier" },
          jsonc = { "prettier" },
          html = { "prettier" },
          css = { "prettier" },
          scss = { "prettier" },
          markdown = { "prettier" },
          yaml = { "prettier" },
          graphql = { "prettier" },
        },
        default_format_opts = {
          timeout_ms = 3000,
          lsp_format = 'fallback',
        },
        format_on_save = function(bufnr)
          -- Disable with a global or buffer-local variable
          if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
            return
          end
          return { timeout_ms = 3000, lsp_format = 'fallback' }
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

  { 'folke/lazydev.nvim', ft = 'lua', opts = {} },
}
