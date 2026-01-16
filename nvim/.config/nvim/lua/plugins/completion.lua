return {
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'rafamadriz/friendly-snippets',
    },
    config = function()
      local cmp = require('cmp')
      local ls = require('luasnip')
      
      require("luasnip.loaders.from_vscode").lazy_load()

      -- Integrate nvim-autopairs with cmp
      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      cmp.event:on(
        'confirm_done',
        cmp_autopairs.on_confirm_done()
      )

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
          { name = 'nvim_lsp', max_item_count = 5 },
          { name = 'buffer',   max_item_count = 3 },
          { name = 'path',     max_item_count = 3 },
          { name = 'luasnip',  max_item_count = 3 },
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-n>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item(cmp_select)
            elseif ls.expand_or_jumpable() then
              ls.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<C-p>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item(cmp_select)
            elseif ls.jumpable(-1) then
              ls.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
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
          expandable_indicator = false,
          fields = { cmp.ItemField.Abbr, cmp.ItemField.Kind, cmp.ItemField.Menu },
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
          { name = 'buffer', max_item_count = 5 }
        }
      })

      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path', max_item_count = 5 }
        }, {
          {
            name = 'cmdline',
            option = {
              ignore_cmds = { 'Man', '!' }
            }
          }
        })
      })

      vim.keymap.set({ "i", "s" }, "<C-l>", function()
        if ls.choice_active() then
          ls.change_choice(1)
        end
      end, { silent = true, desc = "Cycle snippet choice" })
    end
  },
}
