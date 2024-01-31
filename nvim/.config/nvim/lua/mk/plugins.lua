local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    config = function()
      vim.cmd('colorscheme catppuccin-frappe')
    end
  },
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim'
    }
  },
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make',
    cond = function()
      return vim.fn.executable 'make' == 1
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-context',
      'nvim-treesitter/nvim-treesitter-textobjects',
      'andymass/vim-matchup',
    },
    build = function()
      require("nvim-treesitter.install").update({ with_sync = true })()
    end,
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'hrsh7th/nvim-cmp',
      'hrsh7th/cmp-nvim-lsp',
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
      'folke/neodev.nvim',
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
  },
  -- {
  --   'VonHeikemen/lsp-zero.nvim',
  --   branch = 'v3.x',
  --   dependencies = {
  --     'neovim/nvim-lspconfig',
  --     'williamboman/mason.nvim',
  --     'williamboman/mason-lspconfig.nvim',
  --
  --     'hrsh7th/nvim-cmp',
  --     'hrsh7th/cmp-buffer',
  --     'hrsh7th/cmp-path',
  --     -- 'saadparwaiz1/cmp_luasnip',
  --     'hrsh7th/cmp-nvim-lsp',
  --     'hrsh7th/cmp-nvim-lua',
  --
  --     -- 'L3MON4D3/LuaSnip',
  --     -- 'rafamadriz/friendly-snippets',
  --
  --     { 'j-hui/fidget.nvim', tag = 'legacy' },
  --     'folke/neodev.nvim',
  --
  --     'nvimtools/none-ls.nvim',
  --     'jayp0521/mason-null-ls.nvim',
  --   }
  -- },
  -- {
  --   "pmizio/typescript-tools.nvim",
  --   dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  --   config = function()
  --     local nvim_lsp = require('lspconfig')
  --     require("typescript-tools").setup({
  --       settings = {
  --         separate_diagnostic_server = true,
  --         tsserver_max_memory = 8192,
  --         root_dir = nvim_lsp.util.root_pattern("package.json"),
  --       },
  --     })
  --   end,
  -- },
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    tag = 'nightly'
  },
  'lewis6991/gitsigns.nvim',
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',
  'nvim-lualine/lualine.nvim',
  'tpope/vim-sleuth',
  'junegunn/vim-easy-align',
  'mattn/emmet-vim',
  'windwp/nvim-autopairs',
  'windwp/nvim-ts-autotag',
  'mattkubej/jest.nvim',
  'folke/zen-mode.nvim',
  'zbirenbaum/copilot.lua',
  'mbbill/undotree',
  'folke/trouble.nvim',
  {
    'mvllow/modes.nvim',
    config = function()
      require('modes').setup()
    end,
  },
  'tpope/vim-unimpaired',
  'tpope/vim-repeat',
  { "folke/neodev.nvim",         opts = {} },
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'antoinemadec/FixCursorHold.nvim',
      'haydenmeade/neotest-jest'
    },
  },
  { 'echasnovski/mini.surround', version = false },
  { 'echasnovski/mini.comment',  version = false },
  { 'echasnovski/mini.pairs',    version = false },
  'lukas-reineke/indent-blankline.nvim',
  'hedyhli/outline.nvim',
  'RRethy/vim-illuminate',
  'stevearc/aerial.nvim',
}, {})
