require('nvim-treesitter.configs').setup{
  ensure_installed = "all",
  ignore_install = { "haskell", "vala", "r", "beancount", "swift", "markdown" },
  highlight = {
    enable = true,
    disable = { "ocaml" },
  },
  indent = {
    enable = true,
  },
  autotag = {
    enable = true,
  },
  textobjects = {
    move = {
      enable = true,
      goto_next_start = {
        ["]m"] = "@function.outer",
        ["]]"] = "@parameter.inner",
      },
      goto_next_end = {
        ["]M"] = "@function.outer",
        ["]["] = "@parameter.inner",
      },
      goto_previous_start = {
        ["[m"] = "@function.outer",
        ["[["] = "@parameter.inner",
      },
      goto_previous_end = {
        ["[M"] = "@function.outer",
        ["[]"] = "@parameter.inner",
      },
    },
  },
}
