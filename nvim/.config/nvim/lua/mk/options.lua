local opt = vim.opt

opt.guicursor = ""
opt.mouse     = ""

opt.number         = true
opt.relativenumber = true

opt.showmode   = false
opt.hlsearch   = false
opt.scrolloff  = 10

opt.cindent     = true
opt.smartindent = true

opt.expandtab   = true
opt.shiftwidth  = 2
opt.softtabstop = 2
opt.tabstop     = 2

vim.o.undodir  = os.getenv("HOME") .. "/.vimdid"
opt.undofile   = true
opt.swapfile   = false
opt.inccommand = 'split'

opt.tm = 500
opt.updatetime = 50

opt.smartcase = true

opt.colorcolumn   = '80'
opt.signcolumn    = 'yes:1'

opt.foldmethod = 'marker'
opt.foldlevel  = 0
opt.modelines  = 1

opt.joinspaces = false
opt.wrap = false

opt.formatoptions = opt.formatoptions
    - '2'
    - 'a'
    - 'o'
    - 't'
    + 'c'
    + 'j'
    + 'n'
    + 'q'
    + 'r'

vim.g.netrw_dirhistmax = 0 -- do not save any netrw history or bookmarks

opt.clipboard = 'unnamedplus'

opt.laststatus = 3

-- Enable list mode
opt.list = true

-- Configure listchars to show only problematic whitespace
opt.listchars = {
    tab = "→ ",      -- Show actual tab characters
    trail = "·",     -- Show trailing spaces
    extends = "⟩",   -- Show when line continues beyond viewport
    precedes = "⟨",  -- Show when line has content before viewport
    nbsp = "␣",      -- Show non-breaking spaces
    space = "·",  -- DON'T use this with ibl (too noisy)
    eol = "↴",    -- Usually too noisy
}

-- Built-in autocomplete (Neovim 0.12+)
vim.o.completeopt = 'menu,menuone,noselect,fuzzy'
vim.o.autocomplete = true
vim.o.pumborder = 'rounded'
vim.o.pummaxwidth = 40
