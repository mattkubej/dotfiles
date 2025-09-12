return {
  -- {
  --   'nvim-telescope/telescope.nvim',
  --   dependencies = {
  --     'nvim-lua/plenary.nvim',
  --     { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make', enabled = vim.fn.executable("make") == 1, }
  --   },
  --   config = function(_, opts)
  --     require('telescope').load_extension('aerial')
  --     require('telescope').load_extension('fzf')
  --     require('telescope').setup(opts)
  --   end,
  --   opts = function()
  --     local actions = require('telescope.actions')
  --
  --     return {
  --       defaults = {
  --         layout_strategy = 'vertical',
  --         layout_config = {
  --           vertical = {
  --             width = 0.6,
  --           },
  --         },
  --         mappings = {
  --           n = {
  --             ['<C-r>'] = actions.delete_buffer
  --           },
  --           i = {
  --             ['<C-h>'] = 'which_key',
  --             ['<C-r>'] = actions.delete_buffer
  --           }
  --         }
  --       },
  --       pickers = {
  --         find_files = {
  --           find_command = { 'rg', '--files', '--hidden', '-g', '!.git' },
  --         }
  --       },
  --     }
  --   end,
  --   keys = {
  --     { '<leader>?',  function() require('telescope.builtin').oldfiles() end,    desc = '[?] Find recently opened files' },
  --     {
  --       '<leader>/',
  --       function()
  --         require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
  --           winblend = 10,
  --           previewer = false,
  --         })
  --       end,
  --       desc = '[/] Fuzzily search in current buffer'
  --     },
  --     { '<leader>sb', function() require('telescope.builtin').buffers() end,     desc = '[ ] Find existing buffers' },
  --     { '<leader>sf', function() require('telescope.builtin').find_files() end,  desc = '[S]earch [F]iles' },
  --     { '<leader>sh', function() require('telescope.builtin').help_tags() end,   desc = '[S]earch [H]elp' },
  --     { '<leader>sw', function() require('telescope.builtin').grep_string() end, desc = '[S]earch current [W]ord' },
  --     { '<leader>sg', function() require('telescope.builtin').live_grep() end,   desc = '[S]earch by [G]rep' },
  --     { '<leader>sd', function() require('telescope.builtin').diagnostics() end, desc = '[S]earch [D]iagnostics' },
  --     { '<leader>ss', function() require('telescope.builtin').git_status() end,  desc = '[S]earch Git [S]tatus' },
  --     { '<leader>sk', function() require('telescope.builtin').keymaps() end,     desc = '[S]earch [K]eymap' },
  --     {
  --       '<leader>sa',
  --       function()
  --         require('telescope').extensions.aerial.aerial()
  --       end,
  --       desc = '[S]earch [A]erial'
  --     },
  --   },
  -- },
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      'telescope',
      winopts = {
        height = 0.85,
        width = 0.80,
        row = 0.35,
        col = 0.50,
        preview = {
          layout = 'vertical',
          vertical = 'up:55%',
        }
      },
      files = {
        rg_opts = "--color=never --files --hidden --follow -g '!.git' -g '!node_modules'",
      },
      buffers = {
        actions = {
          ['ctrl-r'] = {
            fn = function(...)
              return require('fzf-lua').actions.buf_del(...)
            end,
            reload = true
          },
        }
      }
    },
    keys = {
      { '<leader>sf', function() require('fzf-lua').files() end,                desc = 'FzfLua Files' },
      { '<leader>sg', function() require('fzf-lua').live_grep() end,            desc = 'FzfLua Grep' },
      { '<leader>sb', function() require('fzf-lua').buffers() end,              desc = 'FzfLua Buffers' },
      { '<leader>so', function() require('fzf-lua').oldfiles() end,             desc = 'FzfLua Recent' },
      { '<leader>sh', function() require('fzf-lua').help_tags() end,            desc = 'FzfLua Help' },
      { '<leader>sw', function() require('fzf-lua').grep_cword() end,           desc = 'FzfLua Grep Word' },
      { '<leader>sd', function() require('fzf-lua').diagnostics_document() end, desc = 'FzfLua Diagnostics' },
      { '<leader>ss', function() require('fzf-lua').git_status() end,           desc = 'FzfLua Git Status' },
      { '<leader>sk', function() require('fzf-lua').keymaps() end,              desc = 'FzfLua Keymaps' },
      { '<leader>s/', function() require('fzf-lua').blines() end,               desc = 'FzfLua Buffer Search' },
    }
  }
}
