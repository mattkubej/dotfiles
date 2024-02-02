local ok, gitsigns = pcall(require, 'gitsigns')
if not ok then return end

gitsigns.setup({
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    map('n', '<leader>gb', function() gs.blame_line { full = true } end)
  end
})
