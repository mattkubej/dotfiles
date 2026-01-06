local opt = vim.opt

opt.guicursor = ""
opt.mouse     = ""

opt.number         = true
opt.relativenumber = true

opt.hidden     = true
opt.showmode   = false
opt.hlsearch   = false
opt.scrolloff  = 10

opt.autoindent  = true
opt.cindent     = true
opt.smartindent = true

opt.expandtab   = true
opt.shiftwidth  = 2
opt.softtabstop = 2
opt.tabstop     = 2

opt.laststatus = 2

vim.o.undodir  = os.getenv("HOME") .. "/.vimdid"
opt.undofile   = true
opt.swapfile   = false
opt.inccommand = 'split'

opt.tm = 500
opt.updatetime = 50

opt.incsearch = true
opt.smartcase = true

opt.belloff = 'all'

opt.colorcolumn   = '80'
opt.signcolumn    = 'yes:1'
opt.termguicolors = true

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

-- copilot configuration needs to execute before the plugin is loaded
vim.g.copilot_no_tab_map = true

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
