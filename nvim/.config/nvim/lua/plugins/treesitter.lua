return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    build = ':TSUpdate',
    lazy = false,
    config = function()
      require('nvim-treesitter').setup({})

      -- Install parsers if missing
      local wanted = {
        'javascript', 'typescript', 'tsx',
        'c', 'lua', 'rust', 'go', 'python',
        'ruby', 'gitcommit', 'html', 'css',
        'json', 'yaml', 'markdown', 'markdown_inline',
      }
      local installed = require('nvim-treesitter.config').get_installed()
      local to_install = vim.iter(wanted):filter(function(p)
        return not vim.tbl_contains(installed, p)
      end):totable()
      if #to_install > 0 then
        require('nvim-treesitter').install(to_install)
      end

      -- Enable treesitter highlighting and indentation
      vim.api.nvim_create_autocmd('FileType', {
        callback = function()
          pcall(vim.treesitter.start)
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })

      -- Incremental selection using built-in 0.12 node selection API
      local ts_select = require('vim.treesitter._select')
      vim.keymap.set('n', '<C-space>', function()
        vim.cmd('normal! v')
        ts_select.select_parent(1)
      end, { desc = 'Start incremental selection' })
      vim.keymap.set('x', '<C-space>', function()
        ts_select.select_parent(1)
      end, { desc = 'Expand selection' })
      vim.keymap.set('x', '<BS>', function()
        ts_select.select_child(1)
      end, { desc = 'Shrink selection' })
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    init = function()
      vim.g.no_plugin_maps = true
    end,
    config = function()
      local tso = require('nvim-treesitter-textobjects')
      tso.setup({
        select = {
          lookahead = true,
        },
        move = {
          set_jumps = true,
        },
      })

      local select = require('nvim-treesitter-textobjects.select')
      local move = require('nvim-treesitter-textobjects.move')
      local swap = require('nvim-treesitter-textobjects.swap')

      local function sel(mapping, query, desc)
        vim.keymap.set({ 'x', 'o' }, mapping, function()
          select.select_textobject(query, 'textobjects')
        end, { desc = desc })
      end

      -- Select textobjects
      sel('aa', '@parameter.outer', 'around argument')
      sel('ia', '@parameter.inner', 'inside argument')
      sel('af', '@function.outer', 'around function')
      sel('if', '@function.inner', 'inside function')
      sel('ac', '@class.outer', 'around class')
      sel('ic', '@class.inner', 'inside class')
      sel('ab', '@block.outer', 'around block')
      sel('ib', '@block.inner', 'inside block')
      sel('ai', '@conditional.outer', 'around conditional')
      sel('ii', '@conditional.inner', 'inside conditional')
      sel('al', '@loop.outer', 'around loop')
      sel('il', '@loop.inner', 'inside loop')
      sel('am', '@call.outer', 'around method/call')
      sel('im', '@call.inner', 'inside method/call')
      sel('a/', '@comment.outer', 'around comment')
      sel('ar', '@return.outer', 'around return')
      sel('ir', '@return.inner', 'inside return')
      sel('a=', '@assignment.outer', 'around assignment')
      sel('i=', '@assignment.inner', 'inside assignment')
      sel('l=', '@assignment.lhs', 'assignment LHS')
      sel('r=', '@assignment.rhs', 'assignment RHS')

      -- Move between textobjects
      local function mnext(mapping, query, desc)
        vim.keymap.set({ 'n', 'x', 'o' }, mapping, function()
          move.goto_next_start(query, 'textobjects')
        end, { desc = desc })
      end

      local function mprev(mapping, query, desc)
        vim.keymap.set({ 'n', 'x', 'o' }, mapping, function()
          move.goto_previous_start(query, 'textobjects')
        end, { desc = desc })
      end

      local function mnext_end(mapping, query)
        vim.keymap.set({ 'n', 'x', 'o' }, mapping, function()
          move.goto_next_end(query, 'textobjects')
        end)
      end

      local function mprev_end(mapping, query)
        vim.keymap.set({ 'n', 'x', 'o' }, mapping, function()
          move.goto_previous_end(query, 'textobjects')
        end)
      end

      mnext(']v', '@function.outer', 'Next function')
      mnext(']c', '@class.outer', 'Next class')
      mnext(']a', '@parameter.inner', 'Next argument')
      mnext(']f', '@loop.outer', 'Next loop (for)')
      mnext(']r', '@call.outer', 'Next call (run)')
      mnext(']g', '@comment.outer', 'Next comment (gloss)')
      mnext(']t', '@conditional.outer', 'Next conditional (test)')

      mprev('[v', '@function.outer', 'Previous function')
      mprev('[c', '@class.outer', 'Previous class')
      mprev('[a', '@parameter.inner', 'Previous argument')
      mprev('[f', '@loop.outer', 'Previous loop (for)')
      mprev('[r', '@call.outer', 'Previous call (run)')
      mprev('[g', '@comment.outer', 'Previous comment (gloss)')
      mprev('[t', '@conditional.outer', 'Previous conditional (test)')

      mnext_end(']V', '@function.outer')
      mnext_end(']C', '@class.outer')
      mprev_end('[V', '@function.outer')
      mprev_end('[C', '@class.outer')

      -- Swap parameters
      vim.keymap.set('n', '<leader>a', function()
        swap.swap_next('@parameter.inner')
      end, { desc = 'Swap next argument' })

      vim.keymap.set('n', '<leader>A', function()
        swap.swap_previous('@parameter.inner')
      end, { desc = 'Swap previous argument' })
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter-context',
    opts = {
      max_lines = 3,
    },
  },

  {
    'windwp/nvim-ts-autotag',
    event = 'InsertEnter',
    opts = {},
  },

  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {
      check_ts = true,
    },
  },
}
