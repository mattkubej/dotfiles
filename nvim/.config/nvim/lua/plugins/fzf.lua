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
