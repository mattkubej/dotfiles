local prettier = function()
  return {
    exe = "prettier",
    args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0)},
    stdin = true
  }
end

require('formatter').setup({
  logging = false,
  filetype = {
    javascript = { prettier },
    typescript = { prettier },
    typescriptreact = { prettier },
  }
})

local set_keymap = vim.api.nvim_set_keymap
local opts = { noremap=true, silent=true }

set_keymap('n', '<leader>f', '<cmd>Format<CR>', opts)
