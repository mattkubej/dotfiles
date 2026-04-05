---@type vim.lsp.Config
return {
  cmd = { 'srb', 'tc', '--lsp' },
  filetypes = { 'ruby' },
  root_markers = { 'Gemfile', '.git' },
}
