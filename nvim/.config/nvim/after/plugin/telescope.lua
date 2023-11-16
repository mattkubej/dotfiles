local ok, telescope = pcall(require, 'telescope')
if not ok then return end

telescope.load_extension('aerial')
telescope.load_extension('fzf')

local actions = require('telescope.actions')

telescope.setup{
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
      find_command = {'rg', '--files', '--hidden', '-g', '!.git'},
    }
  },
}

local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>?', builtin.oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader>/', function()
  builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>sb', builtin.buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>ss', builtin.git_status, { desc = '[S]earch Git [S]tatus' })
vim.keymap.set('n', '<leader>sa', function()
  telescope.extensions.aerial.aerial()
end, { desc = '[S]earch [A]erial' })
