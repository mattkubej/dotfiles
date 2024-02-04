return {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make', enabled = vim.fn.executable("make") == 1, }
  },
  config = function(_, opts)
    require('telescope').load_extension('aerial')
    require('telescope').load_extension('fzf')
    require('telescope').setup(opts)
  end,
  opts = function()
    local actions = require('telescope.actions')

    return {
      defaults = {
        layout_strategy = 'vertical',
        mappings = {
          n = {
            ['<C-r>'] = actions.delete_buffer
          },
          i = {
            ['<C-h>'] = 'which_key',
            ['<C-r>'] = actions.delete_buffer
          }
        }
      },
      pickers = {
        find_files = {
          find_command = { 'rg', '--files', '--hidden', '-g', '!.git' },
        }
      },
    }
  end,
  keys = {
    { '<leader>?',  function() require('telescope.builtin').oldfiles() end,    desc = '[?] Find recently opened files' },
    {
      '<leader>/',
      function()
        require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end,
      desc = '[/] Fuzzily search in current buffer'
    },
    { '<leader>sb', function() require('telescope.builtin').buffers() end,     desc = '[ ] Find existing buffers' },
    { '<leader>sf', function() require('telescope.builtin').find_files() end,  desc = '[S]earch [F]iles' },
    { '<leader>sh', function() require('telescope.builtin').help_tags() end,   desc = '[S]earch [H]elp' },
    { '<leader>sw', function() require('telescope.builtin').grep_string() end, desc = '[S]earch current [W]ord' },
    { '<leader>sg', function() require('telescope.builtin').live_grep() end,   desc = '[S]earch by [G]rep' },
    { '<leader>sd', function() require('telescope.builtin').diagnostics() end, desc = '[S]earch [D]iagnostics' },
    { '<leader>ss', function() require('telescope.builtin').git_status() end,  desc = '[S]earch Git [S]tatus' },
    { '<leader>sk', function() require('telescope.builtin').keymaps() end,     desc = '[S]earch [K]eymap' },
    {
      '<leader>sa',
      function()
        require('telescope').extensions.aerial.aerial()
      end,
      desc = '[S]earch [A]erial'
    },
  },
}
