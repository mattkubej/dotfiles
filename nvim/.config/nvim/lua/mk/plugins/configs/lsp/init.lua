local nvim_lsp = require('lspconfig')

local buf_nnoremap = function(bufnr, opts)
  opts.buffer = 0
  vim.api.nvim_buf_set_keymap(bufnr, opts)
end

-- enable null-ls integration
require("null-ls").config {}
require("lspconfig")["null-ls"].setup {}

local ts_utils_attach = function(client, bufnr)
  -- disable tsserver formatting if you plan on formatting via null-ls
  client.resolved_capabilities.document_formatting = false
  client.resolved_capabilities.document_range_formatting = false

  local ts_utils = require("nvim-lsp-ts-utils")

  -- defaults
  ts_utils.setup {
      debug = false,
      disable_commands = false,
      enable_import_on_completion = false,

      -- import all
      import_all_timeout = 5000, -- ms
      import_all_priorities = {
          buffers = 4, -- loaded buffer names
          buffer_content = 3, -- loaded buffer content
          local_files = 2, -- git files or files with relative path markers
          same_file = 1, -- add to existing import statement
      },
      import_all_scan_buffers = 100,
      import_all_select_source = false,

      -- using eslint language server
      eslint_enable_code_actions = false,
      eslint_enable_disable_comments = false,

      -- formatting
      enable_formatting = true,
      formatter = "prettier",
      formatter_opts = {},

      -- update imports on file move
      update_imports_on_move = false,
      require_confirmation_on_move = false,
      watch_dir = nil,

      -- filter diagnostics
      filter_out_diagnostics_by_severity = {},
      filter_out_diagnostics_by_code = {},
  }

  -- required to fix code action ranges and filter diagnostics
  ts_utils.setup_client(client)

  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

  local opts = { silent = true }

  buf_set_keymap("n", "gs", ":TSLspOrganize<CR>", opts)
  buf_set_keymap("n", "gr", ":TSLspRenameFile<CR>", opts)
  buf_set_keymap("n", "gi", ":TSLspImportAll<CR>", opts)
end

local signature_attach = function(client, bufnr)
  require('lsp_signature').on_attach({
    bind = true,
    floating_window = false,
  }, bufnr)
end

local custom_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

  local opts = { noremap=true, silent=true }

  buf_set_keymap('n', 'gdp', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', 'gdn', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', 'gsl', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)

  buf_set_keymap('n', '<c-]>', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)

  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<leader>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

  buf_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)

  signature_attach(client, bufnr)
end

local updated_capabilities = vim.lsp.protocol.make_client_capabilities()
updated_capabilities = require('cmp_nvim_lsp').update_capabilities(updated_capabilities)

local servers = {
  tsserver = {
    on_attach = function(client, bufnr)
      ts_utils_attach(client, bufnr)
      custom_attach(client, bufnr)
    end,
  },
  html = true,
  cssls = true,
  eslint = true,
  graphql = true,
  sumneko_lua = true,
}

local setup_server = function(server, config)
  if not config then
    return
  end

  if type(config) ~= "table" then
    config = {}
  end

  config = vim.tbl_deep_extend("force", {
    on_attach = custom_attach,
    capabilities = updated_capabilities,
    flags = {
      debounce_text_changes = 50,
    },
  }, config)

  nvim_lsp[server].setup(config)
end

for server, config in pairs(servers) do
  setup_server(server, config)
end
