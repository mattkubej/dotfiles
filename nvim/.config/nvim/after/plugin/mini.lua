require('mini.surround').setup({
  mappings = {
    add = "gsa", -- Add surrounding in Normal and Visual modes
    delete = "gsd", -- Delete surrounding
    find = "gsf", -- Find surrounding (to the right)
    find_left = "gsF", -- Find surrounding (to the left)
    highlight = "gsh", -- Highlight surrounding
    replace = "gsr", -- Replace surrounding
    update_n_lines = "gsn", -- Update `n_lines`
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
