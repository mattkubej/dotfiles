require('mason').setup()

require("mason-lspconfig").setup({
    ensure_installed = { "graphql", "ruby-ls", "rust_analyzer", "solargraph", "sorbet", "sumneko_lua", "tsserver",
        "tailwindcss" }
})
