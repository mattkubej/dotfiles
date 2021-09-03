local set_keymap = vim.api.nvim_set_keymap
local opts = { noremap=true, silent=true }

set_keymap('n', '<C-n>', '<cmd>NERDTreeToggle<CR>', opts)
set_keymap('n', '<leader>n', '<cmd>NERDTreeFind<CR>', opts)

vim.g.NERDTreeShowHidden = 1
