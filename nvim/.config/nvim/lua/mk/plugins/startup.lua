return require('packer').startup(function()
  use 'wbthomason/packer.nvim'

  -- nvim extensions
  use 'nvim-lua/plenary.nvim' -- helper lua functions
  use 'nvim-lua/popup.nvim' -- popup api for nvim

  -- text formatting
  use {
    'junegunn/vim-easy-align', -- text alignment
    config = function() require('mk.plugins.configs.easyalign') end
  }
  use 'tpope/vim-surround' -- surround text helpers

  -- git
  use 'junegunn/gv.vim' -- git commit browser
  use 'tpope/vim-fugitive' -- git wrapper
  use {
    'lewis6991/gitsigns.nvim', -- git signs
    requires = {
      'nvim-lua/plenary.nvim'
    },
    config = function() require('gitsigns').setup() end
  }

  -- general language configuration
  use 'editorconfig/editorconfig-vim' -- EditorConfig plugin
  use {
    'neovim/nvim-lspconfig', -- common lsp configurations
    config = function() require("mk.plugins.configs.lsp") end
  }
  use {
    'hrsh7th/nvim-compe', -- lsp auto completion
    config = function() require("mk.plugins.configs.compe") end
  }
  use {
    'scrooloose/nerdcommenter', -- comment functions
    config = function() require('mk.plugins.configs.nerdtree') end
  }
  use 'jxnblk/vim-mdx-js' -- mdx highlighting
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    config = function() require('mk.plugins.configs.treesitter') end
  }
  use 'nvim-treesitter/playground'

  -- language specific plugins
  use 'fatih/vim-go' -- Go language support
  use 'kubejm/jest.nvim' -- jest test runner
  use 'mattn/emmet-vim' -- emmet shortcuts
  use {
    'mhartington/formatter.nvim', -- formatting
    config = function() require('mk.plugins.configs.formatter') end
  }

  -- search/navigation
  use {'junegunn/fzf', dir = '~/.fzf', run = './install --all'}
  use 'junegunn/fzf.vim'
  use {
    'nvim-lua/telescope.nvim', -- fuzzy finder and previewer
    config = function() require('mk.plugins.configs.telescope') end
  }
  use 'scrooloose/nerdtree' -- file explorer

  -- aesthetics
  use {
    'eddyekofo94/gruvbox-flat.nvim', -- gruvbox theme
    config = function() require('mk.plugins.configs.gruvbox-flat') end
  }
  use {
    'hoob3rt/lualine.nvim', -- statusline
    config = function() require('mk.plugins.configs.lualine') end
  }

  -- misc
  use {
    'vimwiki/vimwiki', -- wiki within vim
    config = function() require('mk.plugins.configs.vimwiki') end
  }
  use 'tpope/vim-unimpaired' -- common mappings

  -- possibly unmaintained
  use 'christoomey/vim-tmux-navigator' -- navigative between nvim and tmux
  use 'dag/vim-fish' -- fish script support

  -- testing
  use {
    'norcalli/nvim-colorizer.lua', -- highlight css colors
    config = function() require('mk.plugins.configs.nvim-colorizer') end
  }
  use {
    'windwp/nvim-autopairs',
    config = function() require('mk.plugins.configs.nvim-autopairs') end
  }
  use 'windwp/nvim-ts-autotag' -- auto-closing tags
  use 'tpope/vim-sleuth' -- auto adjust shiftwidth and expand tab
  use 'ray-x/lsp_signature.nvim' -- lsp signature help
  use 'nvim-treesitter/nvim-treesitter-textobjects'
end)
