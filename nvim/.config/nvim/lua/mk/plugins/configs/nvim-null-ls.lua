local status, null_ls = pcall(require, "null-ls")
if (not status) then return end

local formatting = null_ls.builtins.formatting

null_ls.setup({
  sources = {
    null_ls.builtins.diagnostics.eslint_d,
    formatting.prettier,
  },
})
