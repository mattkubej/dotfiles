if pcall(require, 'plenary') then
  RELOAD = require('plenary.reload').reload_module

  R = function(name)
    RELOAD(name)
    return require(name)
  end
end

local should_reload = true
local reloader = function()
  if should_reload then
    RELOAD('plenary')
    RELOAD('popup')
    RELOAD('telescope')
  end
end

reloader()

require('telescope').setup {
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = 'smart_case',
    }
  }
}

require('telescope').load_extension('fzf')

local M = {}

function M.edit_nvim()
  require('telescope.builtin').find_files {
    prompt_title = "~ nvim config ~",
    shorten_path = false,
    cwd = "~/.config/nvim",

    layout_strategy = 'vertical',
  }
end

function M.git_files()
  require('telescope.builtin').git_files {
    prompt_title = "~ git files ~",

    layout_strategy = 'vertical',
  }
end

function M.all_files()
  require('telescope.builtin').find_files {
    prompt_title = "~ all files ~",
    find_command = { 'rg', '--no-ignore', '--files', },

    layout_strategy = 'vertical',
  }
end

function M.lsp_references()
  require('telescope.builtin').lsp_references {
    prompt_title = "~ lsp references ~",

    layout_strategy = 'vertical',
  }
end

function M.fd()
  require('telescope.builtin').fd()
end

function M.grep_prompt()
  require('telescope.builtin').grep_string {
    shorten_path = true,
    search = vim.fn.input("Grep String > "),
  }
end

function M.buffers()
  require('telescope.builtin').buffers {
    shorten_path = false,
  }
end

require('mk.plugins.configs.telescope.mappings')

return setmetatable({}, {
  __index = function(_, k)
    reloader()

    if M[k] then
      return M[k]
    else
      return require('telescope.builtin')[k]
    end
  end
})
