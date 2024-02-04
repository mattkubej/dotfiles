return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    config = function()
      vim.cmd('colorscheme catppuccin-frappe')
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
