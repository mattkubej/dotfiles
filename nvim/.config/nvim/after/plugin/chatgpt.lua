local chatgpt = require("chatgpt")

vim.keymap.set("v", "<leader>ce", function() chatgpt.edit_with_instructions() end)
