return {
  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      {
        'nvim-treesitter/nvim-treesitter-context',
        opts = {
          max_lines = 3,
        }
      },
      'nvim-treesitter/nvim-treesitter-textobjects',
      'windwp/nvim-ts-autotag',
      {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        opts = {
          check_ts = true,
        }
      },
    },
    build = function()
      require("nvim-treesitter.install").update({ with_sync = true })()
    end,
    opts = {
      ensure_installed = {
        "javascript",
        "typescript",
        "c",
        "lua",
        "rust",
        "go",
        "python",
        "gitcommit",
        "tsx",
      },
      sync_install = false,
      auto_install = true,
      indent = {
        enable = true,
      },
      matchup = {
        enable = true,
      },
      highlight = { enable = true, },
      autotag = { enable = true, },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<c-space>',
          node_incremental = '<c-space>',
          scope_incremental = '<c-s>',
          node_decremental = '<bs>',
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            -- Parameter/argument
            ['aa'] = { query = '@parameter.outer', desc = 'around argument' },
            ['ia'] = { query = '@parameter.inner', desc = 'inside argument' },
            -- Function
            ['af'] = { query = '@function.outer', desc = 'around function' },
            ['if'] = { query = '@function.inner', desc = 'inside function' },
            -- Class
            ['ac'] = { query = '@class.outer', desc = 'around class' },
            ['ic'] = { query = '@class.inner', desc = 'inside class' },
            -- Block (if/for/while/etc)
            ['ab'] = { query = '@block.outer', desc = 'around block' },
            ['ib'] = { query = '@block.inner', desc = 'inside block' },
            -- Conditional
            ['ai'] = { query = '@conditional.outer', desc = 'around conditional' },
            ['ii'] = { query = '@conditional.inner', desc = 'inside conditional' },
            -- Loop
            ['al'] = { query = '@loop.outer', desc = 'around loop' },
            ['il'] = { query = '@loop.inner', desc = 'inside loop' },
            -- Call (function call)
            ['am'] = { query = '@call.outer', desc = 'around method/call' },
            ['im'] = { query = '@call.inner', desc = 'inside method/call' },
            -- Comment
            ['a/'] = { query = '@comment.outer', desc = 'around comment' },
            -- Return statement
            ['ar'] = { query = '@return.outer', desc = 'around return' },
            ['ir'] = { query = '@return.inner', desc = 'inside return' },
            -- Assignment
            ['a='] = { query = '@assignment.outer', desc = 'around assignment' },
            ['i='] = { query = '@assignment.inner', desc = 'inside assignment' },
            ['l='] = { query = '@assignment.lhs', desc = 'assignment LHS' },
            ['r='] = { query = '@assignment.rhs', desc = 'assignment RHS' },
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            [']v'] = { query = '@function.outer', desc = 'Next function' },
            [']c'] = { query = '@class.outer', desc = 'Next class' },
            [']a'] = { query = '@parameter.inner', desc = 'Next argument' },
            [']l'] = { query = '@loop.outer', desc = 'Next loop' },
            [']m'] = { query = '@call.outer', desc = 'Next method/call' },
            [']/'] = { query = '@comment.outer', desc = 'Next comment' },
          },
          goto_next_end = {
            [']V'] = '@function.outer',
            [']C'] = '@class.outer',
          },
          goto_previous_start = {
            ['[v'] = { query = '@function.outer', desc = 'Previous function' },
            ['[c'] = { query = '@class.outer', desc = 'Previous class' },
            ['[a'] = { query = '@parameter.inner', desc = 'Previous argument' },
            ['[l'] = { query = '@loop.outer', desc = 'Previous loop' },
            ['[m'] = { query = '@call.outer', desc = 'Previous method/call' },
            ['[/'] = { query = '@comment.outer', desc = 'Previous comment' },
          },
          goto_previous_end = {
            ['[V'] = '@function.outer',
            ['[C'] = '@class.outer',
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ['<leader>a'] = '@parameter.inner',
          },
          swap_previous = {
            ['<leader>A'] = '@parameter.inner',
          },
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)

      local move = require('nvim-treesitter.textobjects.move')
      vim.keymap.set({ 'n', 'x', 'o' }, ']i', function()
        move.goto_next_start('@conditional.outer')
      end, { desc = 'Next conditional' })
      vim.keymap.set({ 'n', 'x', 'o' }, '[i', function()
        move.goto_previous_start('@conditional.outer')
      end, { desc = 'Prev conditional' })
    end,
  },
}
