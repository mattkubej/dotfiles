vim.keymap.set('n', '<leader>gs', vim.cmd.Git, { desc = '[G]it [S]tatus' })
vim.keymap.set('n', '<leader>gp', function() vim.cmd.Git('push') end, { desc = '[G]it [P]ush' })
