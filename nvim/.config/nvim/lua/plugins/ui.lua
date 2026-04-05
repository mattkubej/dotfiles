return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = false,
    priority = 1000,
    config = function()
      require('catppuccin').setup({
        aerial = true,
        fzf = true,
        gitsigns = true,
        illuminate = {
          enabled = true,
          lsp = false
        },
        indent_blankline = {
          enabled = true,
          scope_color = "sapphire",
          colored_indent_levels = false,
        },
        mason = true,
        mini = {
          enabled = true,
        },
        native_lsp = { enabled = true },
        neotest = true,
        nvimtree = true,
        treesitter = true,
        treesitter_context = true,
      })

      vim.cmd('colorscheme catppuccin-frappe')

      local colors = require("catppuccin.palettes").get_palette("frappe")
      vim.api.nvim_set_hl(0, "Whitespace", { fg = colors.surface0 }) -- Very faint
      vim.api.nvim_set_hl(0, "NonText", { fg = colors.surface0 })
    end
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'catppuccin' },
    opts = {
      options = {
        theme = 'catppuccin',
        icons_enabled = false,
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'hostname' },
        lualine_c = { 'branch', { 'filename', path = 1 }, 'aerial' },
        lualine_x = {
          { function() return vim.lsp.status() end, cond = function() return vim.lsp.status() ~= '' end },
          'diff', 'encoding', 'fileformat',
        },
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
      extensions = { 'fugitive', 'fzf' }
    }
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
    'mvllow/modes.nvim',
    config = function()
      require('modes').setup()
    end,
  },
  {
    'shortcuts/no-neck-pain.nvim',
    lazy = false,
    opts = {
      width = 140,
      autocmds = {
        enableOnVimEnter = true,
        skipEnteringNoNeckPainBuffer = true,
      },
      mappings = {
        enabled = true,
        toggle = "<leader>z",
      },
      buffers = {
        wo = {
          fillchars = "eob: ",
        },
        colors = {
          background = "catppuccin-mocha",
        }
      },
      integrations = {
        aerial = {
          position = "right",
          reopen = true,
        },
      },
    },
  }
}
