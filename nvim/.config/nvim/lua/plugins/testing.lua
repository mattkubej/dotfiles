return {
  'mattkubej/jest.nvim',
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'antoinemadec/FixCursorHold.nvim',
      'haydenmeade/neotest-jest'
    },
    opts = function()
      return {
        adapters = {
          require('neotest-jest')({
            jestCommand = "npm test -- --watch",
          }),
        },
      }
    end,
    keys = {
      { "<leader>tw", "<cmd>lua require('neotest').run.run()<cr>" },
      { "<leader>tf", "<cmd>lua require('neotest').run.run(vim.fn.expand(\"%\"))<cr>" },
      { "<leader>ts", "<cmd>lua require('neotest').run.stop()<cr>" },
      { "<leader>ta", "<cmd>lua require('neotest').run.attach()<cr>" },
      { "<leader>to", "<cmd>lua require('neotest').output_panel.toggle({ last_run = true })<cr>" },
    },
  }
}
