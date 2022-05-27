require'nvim-tree'.setup {
  auto_reload_on_write = false,
  git = {
    enable = false,
    ignore = false,
  }
}

local set_keymap = vim.api.nvim_set_keymap
local opts = { noremap=true, silent=true }

set_keymap('n', '<C-n>', '<cmd>NvimTreeToggle<CR>', opts)
set_keymap('n', '<leader>n', '<cmd>NvimTreeFindFile<CR>', opts)
