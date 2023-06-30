require("neotest").setup({
  adapters = {
    require('neotest-jest')({
      jestCommand = "npm test -- --watch",
    }),
  },
})

vim.api.nvim_set_keymap("n", "<leader>tw", "<cmd>lua require('neotest').run.run()<cr>", {})
vim.api.nvim_set_keymap("n", "<leader>tf", "<cmd>lua require('neotest').run.run(vim.fn.expand(\"%\"))<cr>", {})
vim.api.nvim_set_keymap("n", "<leader>ts", "<cmd>lua require('neotest').run.stop()<cr>", {})
vim.api.nvim_set_keymap("n", "<leader>ta", "<cmd>lua require('neotest').run.attach()<cr>", {})
vim.api.nvim_set_keymap("n", "<leader>to", "<cmd>lua require('neotest').output_panel.toggle({ last_run = true })<cr>", {})
