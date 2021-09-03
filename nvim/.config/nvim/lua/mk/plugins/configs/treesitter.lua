require('nvim-treesitter.configs').setup{
  ensure_installed = "all",
  ignore_install = { "haskell" },
  highlight = {
    enable = true,
    disable = { "ocaml" },
  },
}
