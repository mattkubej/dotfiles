require('material').setup({
    contrast = {
        terminal = false,
        sidebars = false,
        floating_windows = false,
        cursor_line = false,
        non_current_windows = false,
        filetypes = {},
    },

    styles = {
        comments = {},
        strings = {},
        keywords = {},
        functions = {},
        variables = {},
        operators = {},
        types = {},
    },

    plugins = {
        "gitsigns",
        "nvim-cmp",
        "telescope",
    },

    disable = {
        colored_cursor = false,
        borders = false,
        background = false,
        term_colors = false,
        eob_lines = false
    },

    high_visibility = {
        lighter = false,
        darker = false
    },

    lualine_style = "default",

    async_loading = true,

    custom_colors = nil,

    custom_highlights = {},
})


vim.g.base16colorspace = 256
vim.g.material_style = "palenight"
vim.cmd[[colorscheme material]]
