return {
  'tpope/vim-sleuth',
  'tpope/vim-unimpaired',
  'tpope/vim-repeat',
  'mattn/emmet-vim',
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
  {
    'junegunn/vim-easy-align',
    keys = {
      { 'ga', '<Plug>(EasyAlign)', mode = 'x', desc = 'Easy align' },
      { 'ga', '<Plug>(EasyAlign)', mode = 'n', desc = 'Easy align' },
    }
  },
  {
    'mbbill/undotree',
    cmd = "UndotreeToggle",
    keys = {
      { "<leader>u", vim.cmd.UndotreeToggle, desc = "Toggle Undotree" },
    },
  },
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
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
    'stevearc/oil.nvim',
    opts = {},
    cmd = "Oil",
    keys = {
      { "<C-e>", function() require('oil').toggle_float(vim.fn.getcwd()) end, desc = "Open oil in parent directory" },
      {
        "<leader>e",
        function()
          local oil = require('oil')
          oil.toggle_float(oil.get_current_dir())
        end,
        desc = "Open oil in current directory"
      }
    }
  },
  {
    'folke/trouble.nvim',
    opts = {},
    keys = {
      { "<leader>xx", function() require('trouble').toggle() end, desc = "Toggle Trouble" },
      { "<leader>xw", function() require('trouble').toggle('workspace_diagnostics') end, desc = "Workspace diagnostics" },
      { "<leader>xd", function() require('trouble').toggle('document_diagnostics') end, desc = "Document diagnostics" },
      { "<leader>xl", function() require('trouble').toggle('loclist') end, desc = "Location list" },
      { "<leader>xq", function() require('trouble').toggle('quickfix') end, desc = "Quickfix list" },
      { "<leader>xr", function() require('trouble').toggle('lsp_references') end, desc = "LSP references" },
    },
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
    'folke/flash.nvim',
    event = 'VeryLazy',
    opts = {},
    keys = {
      { '<leader>j', function() require('flash').jump() end, mode = { 'n', 'x', 'o' }, desc = 'Flash jump' },
      { '<leader>J', function() require('flash').treesitter() end, mode = { 'n', 'x', 'o' }, desc = 'Flash treesitter' },
    },
  },
  {
    'stevearc/aerial.nvim',
    opts = {
      on_attach = function(bufnr)
        vim.keymap.set("n", "[[", "<cmd>AerialPrev<CR>", { buffer = bufnr })
        vim.keymap.set("n", "]]", "<cmd>AerialNext<CR>", { buffer = bufnr })
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
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup({})
    end,
    keys = {
      {
        "<leader>ho",
        function()
          local harpoon = require('harpoon')
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end,
        desc = "Toggle Harpoon"
      },
      {
        "<leader>ha",
        function()
          local harpoon = require('harpoon')
          harpoon:list():append()
        end,
        desc = "Add current file to Harpoon"
      },
      {
        "<leader>hr",
        function()
          local harpoon = require('harpoon')
          harpoon:list():remove()
        end,
        desc = "Remove file from Harpoon"
      },
      {
        "<leader>hc",
        function()
          local harpoon = require('harpoon')
          harpoon:list():clear()
        end,
        desc = "Clear Harpoon list"
      },
      {
        "<leader>1",
        function()
          local harpoon = require('harpoon')
          harpoon:list():select(1)
        end,
        desc = "Harpoon select 1"
      },
      {
        "<leader>2",
        function()
          local harpoon = require('harpoon')
          harpoon:list():select(2)
        end,
        desc = "Harpoon select 2"
      },
      {
        "<leader>3",
        function()
          local harpoon = require('harpoon')
          harpoon:list():select(3)
        end,
        desc = "Harpoon select 3"
      },
      {
        "<leader>4",
        function()
          local harpoon = require('harpoon')
          harpoon:list():select(4)
        end,
        desc = "Harpoon select 4"
      },
      {
        "<leader>5",
        function()
          local harpoon = require('harpoon')
          harpoon:list():select(5)
        end,
        desc = "Harpoon select 5"
      },
      {
        "<leader>hn",
        function()
          local harpoon = require('harpoon')
          harpoon:list():next()
        end,
        desc = "Harpoon next"
      },
      {
        "<leader>hp",
        function()
          local harpoon = require('harpoon')
          harpoon:list():prev()
        end,
        desc = "Harpoon previous"
      },
    }
  },
}
