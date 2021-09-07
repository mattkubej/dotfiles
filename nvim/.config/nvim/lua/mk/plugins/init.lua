return require('packer').startup(function()
  use 'wbthomason/packer.nvim'

  -- nvim extensions
  use 'nvim-lua/plenary.nvim' -- helper lua functions
  use 'nvim-lua/popup.nvim' -- popup api for nvim

  -- text formatting
  use {
    'junegunn/vim-easy-align', -- text alignment
    config = [[require('mk.plugins.configs.easyalign')]]
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
    config = [[require('mk.plugins.configs.gitsigns')]]
  }

  -- general language configuration
  use 'editorconfig/editorconfig-vim' -- EditorConfig plugin
  use {
    'neovim/nvim-lspconfig', -- common lsp configurations
    config = [[require("mk.plugins.configs.lsp")]]
  }
  use {
    'hrsh7th/nvim-compe', -- lsp auto completion
    config = [[require("mk.plugins.configs.compe")]]
  }
  use {
    'scrooloose/nerdcommenter', -- comment functions
    config = [[require('mk.plugins.configs.nerdtree')]]
  }
  use 'jxnblk/vim-mdx-js' -- mdx highlighting
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    config = [[require('mk.plugins.configs.treesitter')]]
  }

  -- language specific plugins
  use 'fatih/vim-go' -- Go language support
  use 'kubejm/jest.nvim' -- jest test runner
  use 'mattn/emmet-vim' -- emmet shortcuts
  use {
    'mhartington/formatter.nvim', -- formatting
    config = [[require('mk.plugins.configs.formatter')]]
  }

  -- search/navigation
  use {'junegunn/fzf', dir = '~/.fzf', run = './install --all'}
  use 'junegunn/fzf.vim'
  use {
    'nvim-lua/telescope.nvim', -- fuzzy finder and previewer
    config = [[require('mk.plugins.configs.telescope')]]
  }
  use 'scrooloose/nerdtree' -- file explorer

  -- aesthetics
  use {
    'eddyekofo94/gruvbox-flat.nvim', -- gruvbox theme
    config = [[require('mk.plugins.configs.gruvbox-flat')]]
  }
  use {
    'hoob3rt/lualine.nvim', -- statusline
    config = [[require('mk.plugins.configs.lualine')]]
  }

  -- misc
  use {
    'vimwiki/vimwiki', -- wiki within vim
    config = [[require('mk.plugins.configs.vimwiki')]]
  }
  use 'tpope/vim-unimpaired' -- common mappings

  -- possibly unmaintained
  use 'christoomey/vim-tmux-navigator' -- navigative between nvim and tmux
  use 'dag/vim-fish' -- fish script support
end)

