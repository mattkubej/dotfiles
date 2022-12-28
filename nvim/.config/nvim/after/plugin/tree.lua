require('nvim-tree').setup({
  auto_reload_on_write = false,
  git = {
    enable = false,
    ignore = false,
  }
})

vim.keymap.set("n", "<C-n>", vim.cmd.NvimTreeToggle)
vim.keymap.set("n", "<leader>n", vim.cmd.NvimTreeFindFile)
