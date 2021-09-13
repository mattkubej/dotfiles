require('compe').setup {
  enabled = true;
  autocomplete = true;
  debug = false;
  min_length = 1;
  preselect = 'enable';
  throttle_time = 80;
  source_timeout = 200;
  resolve_timeout = 800;
  incomplete_delay = 400;
  max_abbr_width = 100;
  max_kind_width = 100;
  max_menu_width = 100;
  documentation = {
    border = { '', '' ,'', ' ', '', '', '', ' ' }, -- the border option is the same as `|help nvim_open_win|`
    winhighlight = "NormalFloat:CompeDocumentation,FloatBorder:CompeDocumentationBorder",
    max_width = 120,
    min_width = 60,
    max_height = math.floor(vim.o.lines * 0.3),
    min_height = 1,
  };

  source = {
    path = true;
    buffer = true;
    calc = true;
    nvim_lsp = true;
    nvim_lua = true;
    vsnip = true;
    ultisnips = true;
    luasnip = true;
  };
}

local set_keymap = vim.api.nvim_set_keymap
local opts = { noremap=true, silent=true, expr=true }

set_keymap('i', '<C-Space>', 'compe#complete()', opts)
set_keymap('i', '<CR>', "compe#confirm(luaeval(\"require 'nvim-autopairs'.autopairs_cr()\"))", opts)
set_keymap('i', '<C-e>', "compe#close('<C-e>')", opts)
set_keymap('i', '<C-f>', "compe#scroll({ 'delta': +4 })", opts)
set_keymap('i', '<C-d>', "compe#scroll({ 'delta': -4 })", opts)
