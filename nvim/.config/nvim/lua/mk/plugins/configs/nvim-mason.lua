require('mason').setup()

require("mason-lspconfig").setup({
    ensure_installed = { "graphql", "rust_analyzer", "solargraph", "sumneko_lua", "tsserver", "tailwindcss" }
})
