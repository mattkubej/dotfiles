-- vim.keymap.set("i", "<C-j>", 'copilot#Accept("")', {expr = true, replace_keycodes = false})

require("copilot").setup({
  suggestion = {
    auto_trigger = true,
  },
})
