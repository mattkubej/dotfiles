local ok, lualine = pcall(require, 'lualine')
if not ok then return end

lualine.setup({
  options = {
    theme = 'catppuccin',
    icons_enabled = false,
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'hostname' },
    lualine_c = { 'branch', 'filename', 'diff' },
    lualine_x = { 'encoding', 'fileformat' }, -- filetype causes lag
    lualine_y = { 'progress' },
    lualine_z = { 'location'  },
  },
  extensions = { 'fugitive', 'fzf' }
})
