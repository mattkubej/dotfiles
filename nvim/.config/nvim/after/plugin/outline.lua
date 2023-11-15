local ok, outline = pcall(require, 'outline')
if not ok then return end

outline.setup()

vim.keymap.set("n", "<leader>tt", '<cmd>Outline<CR>')
