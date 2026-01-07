return {
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        map('n', ']h', function()
          if vim.wo.diff then
            vim.cmd.normal({ ']h', bang = true })
          else
            gs.nav_hunk('next')
          end
        end)

        map('n', '[h', function()
          if vim.wo.diff then
            vim.cmd.normal({ '[h', bang = true })
          else
            gs.nav_hunk('prev')
          end
        end)

        map('n', '<leader>gb', function() gs.blame_line { full = true } end)
      end
    }
  },
  {
    'tpope/vim-fugitive',
    dependencies = {
      'tpope/vim-rhubarb',
    },
    keys = {
      { '<leader>gs', vim.cmd.Git,                        desc = '[G]it [S]tatus' },
      { '<leader>gp', function() vim.cmd.Git('push') end, desc = '[G]it [P]ush' },
    },
    cmd = { 'Git', 'GBrowse' },
  },
  {
    'linrongbin16/gitlinker.nvim',
    cmd = "GitLink",
    opts = {},
    keys = {
      { '<leader>gl', '<cmd>GitLink<cr>',  mode = { 'n', 'v' }, desc = '[G]it [L]ink (copy)' },
      { '<leader>gL', '<cmd>GitLink!<cr>', mode = { 'n', 'v' }, desc = '[G]it [L]ink (open)' },
    },
  },
  {
    "kdheepak/lazygit.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      vim.keymap.set('n', '<leader>gg', vim.cmd.LazyGit, { desc = 'LazyGit' })
    end
  }
}
