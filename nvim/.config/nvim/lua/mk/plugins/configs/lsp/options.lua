--  https://github.com/neovim/neovim/pull/13479
local opt = vim.opt

vim.cmd [[set shortmess+=c]]

opt.completeopt = {'menuone', 'noselect'}

vim.g.completion_matching_strategy_list = {'exact', 'substring', 'fuzzy'}
