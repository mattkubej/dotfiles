local ok, zenmode = pcall(require, 'zen-mode')
if not ok then return end

zenmode.setup {
    window = {
        width = 120,
        options = {
            number = true,
            relativenumber = true,
        }
    },
}

vim.keymap.set("n", "<leader>zz", function()
    zenmode.toggle()
    vim.wo.wrap = false
end)
