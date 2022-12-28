local set_keymap = vim.api.nvim_set_keymap
local opts = { noremap=true, silent=true }

set_keymap('i', '<C-c>', '<esc>', { noremap=true })

set_keymap('n', '<leader><leader>', '<c-^>', opts)

set_keymap('n', '<leader>+', '<cmd>vertical resize +5<CR>', opts)
set_keymap('n', '<leader>-', '<cmd>vertical resize -5<CR>', opts)

set_keymap('v', 'J', ":m '>+1<CR>gv=gv", { noremap=true })
set_keymap('v', 'K', ":m '<-2<CR>gv=gv", { noremap=true })
