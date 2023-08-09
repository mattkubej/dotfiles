require('mini.surround').setup({
  mappings = {
    add = "gza", -- Add surrounding in Normal and Visual modes
    delete = "gzd", -- Delete surrounding
    find = "gzf", -- Find surrounding (to the right)
    find_left = "gzF", -- Find surrounding (to the left)
    highlight = "gzh", -- Highlight surrounding
    replace = "gzr", -- Replace surrounding
    update_n_lines = "gzn", -- Update `n_lines`
  },
})
require('mini.comment').setup()
require('mini.pairs').setup()
-- require('mini.indentscope').setup({
--   draw = {
--     animation = require('mini.indentscope').gen_animation.none()
--   },
--   symbol = '┊',
-- })
