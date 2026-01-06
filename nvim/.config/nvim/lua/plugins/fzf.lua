return {
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
      -- File/buffer search
      { '<leader>sf', function() require('fzf-lua').files() end,                desc = 'Find files' },
      { '<leader>sb', function() require('fzf-lua').buffers() end,              desc = 'Find buffers' },
      { '<leader>so', function() require('fzf-lua').oldfiles() end,             desc = 'Find recent files' },
      -- Text search
      { '<leader>sg', function() require('fzf-lua').live_grep() end,            desc = 'Grep (live)' },
      { '<leader>sw', function() require('fzf-lua').grep_cword() end,           desc = 'Grep word under cursor' },
      { '<leader>sW', function() require('fzf-lua').grep_cWORD() end,           desc = 'Grep WORD under cursor' },
      { '<leader>sv', function() require('fzf-lua').grep_visual() end, mode = 'v', desc = 'Grep visual selection' },
      { '<leader>s/', function() require('fzf-lua').blines() end,               desc = 'Search in buffer' },
      -- LSP symbols (elite navigation)
      { '<leader>sS', function() require('fzf-lua').lsp_document_symbols() end, desc = 'Document symbols' },
      { '<leader>sP', function() require('fzf-lua').lsp_workspace_symbols() end, desc = 'Workspace symbols' },
      -- Diagnostics
      { '<leader>sd', function() require('fzf-lua').diagnostics_document() end, desc = 'Document diagnostics' },
      { '<leader>sD', function() require('fzf-lua').diagnostics_workspace() end, desc = 'Workspace diagnostics' },
      -- Git
      { '<leader>ss', function() require('fzf-lua').git_status() end,           desc = 'Git status' },
      { '<leader>sc', function() require('fzf-lua').git_commits() end,          desc = 'Git commits' },
      { '<leader>sB', function() require('fzf-lua').git_branches() end,         desc = 'Git branches' },
      -- Help/discovery
      { '<leader>sh', function() require('fzf-lua').help_tags() end,            desc = 'Help tags' },
      { '<leader>sk', function() require('fzf-lua').keymaps() end,              desc = 'Keymaps' },
      { '<leader>s:', function() require('fzf-lua').command_history() end,      desc = 'Command history' },
      { '<leader>sr', function() require('fzf-lua').registers() end,            desc = 'Registers' },
      { '<leader>sm', function() require('fzf-lua').marks() end,                desc = 'Marks' },
      { '<leader>sj', function() require('fzf-lua').jumps() end,                desc = 'Jump list' },
      -- Resume last search
      { '<leader><CR>', function() require('fzf-lua').resume() end,             desc = 'Resume last search' },
    }
  }
}
