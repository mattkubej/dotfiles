---@type vim.lsp.Config
return {
  cmd = { 'stylelint-lsp', '--stdio' },
  filetypes = {
    'css',
    'html',
    'less',
    'scss',
  },
  root_markers = {
    '.stylelintrc',
    '.stylelintrc.json',
    '.stylelintrc.yaml',
    '.stylelintrc.yml',
    '.stylelintrc.js',
    '.stylelintrc.cjs',
    '.stylelintrc.mjs',
    'stylelint.config.js',
    'stylelint.config.cjs',
    'stylelint.config.mjs',
    '.git',
  },
}
