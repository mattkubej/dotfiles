return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    config = function()
      vim.cmd('colorscheme catppuccin-frappe')
    end
  },
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
    end
  },
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
    },
    config = function()
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
    end
  },
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    tag = 'nightly',
    opts = {
      auto_reload_on_write = false,
      git = {
        enable = false,
        ignore = false,
      },
      view = {
        relativenumber = true,
        float = {
          enable = true,
          open_win_config = function()
            local screen_w = vim.opt.columns:get()
            local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
            local window_w = screen_w * 0.5
            local window_h = screen_h * 0.8
            local window_w_int = math.floor(window_w)
            local window_h_int = math.floor(window_h)
            local center_x = (screen_w - window_w) / 2
            local center_y = ((vim.opt.lines:get() - window_h) / 2)
                - vim.opt.cmdheight:get()
            return {
              border = "rounded",
              relative = "editor",
              row = center_y,
              col = center_x,
              width = window_w_int,
              height = window_h_int,
            }
          end,
        },
        width = function()
          return math.floor(vim.opt.columns:get() * 0.5)
        end,
      },
    },
    keys = {
      { "<C-n>",     vim.cmd.NvimTreeToggle },
      { "<leader>n", vim.cmd.NvimTreeFindFile },
    },
  },
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        map('n', '<leader>gb', function() gs.blame_line { full = true } end)
      end
    }
  },
  {
    'tpope/vim-fugitive',
    keys = {
      { '<leader>gs', vim.cmd.Git,                        desc = '[G]it [S]tatus' },
      { '<leader>gp', function() vim.cmd.Git('push') end, desc = '[G]it [P]ush' },
    }
  },
  'tpope/vim-rhubarb',
  {
    'nvim-lualine/lualine.nvim',
    opts = {
      options = {
        theme = 'catppuccin',
        icons_enabled = false,
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'hostname' },
        lualine_c = { 'branch', { 'filename', path = 1 }, 'aerial' },
        lualine_x = { 'diff', 'encoding', 'fileformat' }, -- filetype causes lag
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
      extensions = { 'fugitive', 'fzf' }
    }
  },
  'tpope/vim-sleuth',
  {
    'junegunn/vim-easy-align',
    keys = {
      { 'ga', '<Plug>(EasyAlign)', mode = 'x', desc = 'Easy align' },
      { 'ga', '<Plug>(EasyAlign)', mode = 'n', desc = 'Easy align' },
    }
  },
  'mattn/emmet-vim',
  'windwp/nvim-autopairs',
  'windwp/nvim-ts-autotag',
  {
    'folke/zen-mode.nvim',
    opts = {
      window = {
        width = 120,
        options = {
          number = true,
          relativenumber = true,
        }
      },
    },
    cmd = "ZenMode",
    keys = {
      { "<leader>zz", vim.cmd.ZenMode, desc = "Toggle Zen Mode" },
    },
  },
  {
    'zbirenbaum/copilot.lua',
    opts = {
      suggestion = {
        auto_trigger = true,
        keymap = {
          accept = "<C-j>",
        }
      },
    }
  },
  {
    'mbbill/undotree',
    cmd = "UndotreeToggle",
    opts = {
      keys = {
        { "<leader>u", vim.cmd.UndotreeToggle },
      },
    },
  },
  {
    'folke/trouble.nvim',
    opts = {

      keys = {
        { "<leader>xx", vim.cmd.TroubleToggle },
        { "<leader>xw", function() vim.cmd.TroubleToggle('workspace_diagnostics') end },
        { "<leader>xd", function() vim.cmd.TroubleToggle('document_diagnostics') end },
        { "<leader>xl", function() vim.cmd.TroubleToggle('loclist') end },
        { "<leader>xq", function() vim.cmd.TroubleToggle('quickfix') end },
        { "<leader>xr", function() vim.cmd.TroubleToggle('lsp_references') end },
      }
    },
  },
  {
    'mvllow/modes.nvim',
    config = function()
      require('modes').setup()
    end,
  },
  'tpope/vim-unimpaired',
  'tpope/vim-repeat',
  { "folke/neodev.nvim",        opts = {} },
  {
    'echasnovski/mini.surround',
    opts = {
      mappings = {
        add = "gsa",            -- Add surrounding in Normal and Visual modes
        delete = "gsd",         -- Delete surrounding
        find = "gsf",           -- Find surrounding (to the right)
        find_left = "gsF",      -- Find surrounding (to the left)
        highlight = "gsh",      -- Highlight surrounding
        replace = "gsr",        -- Replace surrounding
        update_n_lines = "gsn", -- Update `n_lines`
      },
    },
    version = false
  },
  { 'echasnovski/mini.comment', opts = {}, version = false },
  { 'echasnovski/mini.pairs',   opts = {}, version = false },
  {
    'lukas-reineke/indent-blankline.nvim',
    main = "ibl",
    opts = {
      indent = {
        char = '┊',
      },
      scope = {
        enabled = true,
        show_start = false,
        highlight = { "Function", "Label" },
        priority = 500,
      }
    }
  },
  {
    'hedyhli/outline.nvim',
    opts = {
      outline_window = {
        show_numbers = true,
        show_relative_numbers = true,
      },
    },
    keys = {
      { '<leader>tt', '<cmd>Outline<CR>', desc = "Toggle outline" }
    },
  },
  {
    'RRethy/vim-illuminate',
    config = function()
      require('illuminate').configure({
        providers = { 'lsp', 'treesitter' },
        delay = 200,
        large_file_cutoff = 2000,
        large_file_overrides = {
          providers = { 'lsp' },
        }
      })
    end,
  },
  {
    'stevearc/aerial.nvim',
    opts = {
      on_attach = function(bufnr)
        vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
        vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
      end,
      layout = {
        min_width = 0.1,
        max_width = 0.2,
      },
    },
    keys = {
      { "<leader>co", "<cmd>AerialToggle!<CR>", desc = "Toggle Aerial" }
    }
  },
  {
    "kdheepak/lazygit.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      vim.keymap.set('n', '<leader>gg', vim.cmd.LazyGit, { desc = 'LazyGit' })
    end
  }
}
