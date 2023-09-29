local ok, indent_blankline = pcall(require, 'ibl')
if not ok then return end

indent_blankline.setup {
  indent = {
    char = '┊',
  },
  scope = {
    enabled = true,
  }
}
