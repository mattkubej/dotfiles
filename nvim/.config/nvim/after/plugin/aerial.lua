local ok, aerial = pcall(require, 'aerial')
if not ok then return end

aerial.setup({
  on_attach = function(bufnr)
    vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
    vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
  end,
  layout = {
    min_width = 0.1,
    max_width = 0.2,
  },
})

vim.keymap.set("n", "<leader>co", "<cmd>AerialToggle!<CR>")
