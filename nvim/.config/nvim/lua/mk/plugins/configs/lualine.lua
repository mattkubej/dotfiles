require('lualine').setup({
  options = {
    theme = 'gruvbox-flat',
    icons_enabled = false,
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'hostname' },
    lualine_c = { 'branch', 'filename' },
    lualine_x = { 'encoding', 'fileformat' }, -- filetype causes lag
    lualine_y = { 'progress' },
    lualine_z = { 'location'  },
  },
  extensions = { 'fugitive', 'fzf', 'nerdtree' }
})
