local ok, illuminate = pcall(require, 'illuminate')
if not ok then return end

illuminate.configure({
  providers = { 'lsp', 'treesitter' },
  delay = 200,
  large_file_cutoff = 2000,
  large_file_overrides = {
    providers = { 'lsp' },
  }
})
