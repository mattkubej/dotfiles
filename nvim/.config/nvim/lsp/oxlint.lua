---@type vim.lsp.Config
return {
  cmd = function(dispatchers, config)
    local cmd = {'pnpm', 'exec', 'oxlint', '--lsp'}
    local local_bin = config.root_dir and (config.root_dir .. '/node_modules/.bin/oxlint')

    if local_bin and vim.uv.fs_stat(local_bin) then
      cmd = {local_bin, '--lsp'}
    end

    return vim.lsp.rpc.start(cmd, dispatchers, {cwd = config.root_dir})
  end,
  filetypes = {
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx',
  },
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, {
      'oxlint.config.ts',
      'oxlint.config.js',
      'oxlint.config.mjs',
      'oxlint.config.cjs',
      '.oxlintrc.json',
      '.oxlintrc.jsonc',
    })

    if root then
      on_dir(root)
    end
  end,
}
