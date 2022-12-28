local opt = vim.opt

opt.guicursor      = ""

opt.number         = true
opt.relativenumber = true

opt.hidden         = true
opt.showmode       = false
opt.updatetime     = 1000
opt.hlsearch       = false
opt.scrolloff      = 10

opt.autoindent     = true
opt.cindent        = true
opt.smartindent    = true

opt.expandtab      = true
opt.shiftwidth     = 2
opt.softtabstop    = 2
opt.tabstop        = 2

opt.clipboard      = 'unnamedplus'
opt.laststatus     = 2

opt.undodir        = vim.fn.expand('$HOME/.vimdid//')
opt.undofile       = true
opt.swapfile       = false
opt.inccommand     = 'split'

opt.tm             = 500

opt.incsearch      = true
opt.smartcase      = true

opt.belloff        = 'all'

opt.colorcolumn    = '80'
opt.signcolumn     = 'yes:1'
opt.termguicolors  = true

opt.wrap           = false

opt.foldmethod     = 'marker'
opt.foldlevel      = 0
opt.modelines      = 1

opt.joinspaces     = false

opt.updatetime     = 50

opt.formatoptions  = opt.formatoptions
                     - '2'
                     - 'a'
                     - 'o'
                     - 't'
                     + 'c'
                     + 'j'
                     + 'n'
                     + 'q'
                     + 'r'

vim.g.etrw_dirhistmax = 0 -- do not save any netrw history or bookmarks
