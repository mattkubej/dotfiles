vim.g.mapleader = " "

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Open netrw" })

vim.keymap.set("i", "<C-c>", "<esc>", { desc = "Exit insert mode" })

vim.keymap.set("n", "<leader><leader>", "<c-^>", { desc = "Alternate file" })

vim.keymap.set("n", "<leader>+", "<cmd>vertical resize +5<CR>", { desc = "Increase window width" })
vim.keymap.set("n", "<leader>-", "<cmd>vertical resize -5<CR>", { desc = "Decrease window width" })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines (cursor stays)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "{", "{zz", { desc = "Prev paragraph (centered)" })
vim.keymap.set("n", "}", "}zz", { desc = "Next paragraph (centered)" })
vim.keymap.set("n", "N", "Nzz", { desc = "Prev search (centered)" })
vim.keymap.set("n", "n", "nzz", { desc = "Next search (centered)" })
vim.keymap.set("n", "G", "Gzz", { desc = "Go to end (centered)" })
vim.keymap.set("n", "gg", "ggzz", { desc = "Go to start (centered)" })
vim.keymap.set("n", "<C-i>", "<C-i>zz", { desc = "Jump forward (centered)" })
vim.keymap.set("n", "<C-o>", "<C-o>zz", { desc = "Jump back (centered)" })
vim.keymap.set("n", "%", "%zz", { desc = "Match bracket (centered)" })
vim.keymap.set("n", "*", "*zz", { desc = "Search word forward (centered)" })
vim.keymap.set("n", "#", "#zz", { desc = "Search word backward (centered)" })

vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without yanking" })

vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank line to clipboard" })

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete to black hole" })

vim.keymap.set("n", "<leader>rw", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace word under cursor" })

vim.keymap.set("n", "<leader>w", "<cmd>update<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>wq", "<cmd>wq<CR>", { desc = "Save and quit" })
vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })

