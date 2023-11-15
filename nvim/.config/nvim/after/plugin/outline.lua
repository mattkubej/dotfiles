local ok, outline = pcall(require, 'outline')
if not ok then return end

outline.setup({
  outline_window = {
    show_numbers = true,
    show_relative_numbers = true,
  },
})

vim.keymap.set("n", "<leader>tt", '<cmd>Outline<CR>')
