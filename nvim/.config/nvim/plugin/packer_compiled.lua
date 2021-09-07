-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

  local time
  local profile_info
  local should_profile = false
  if should_profile then
    local hrtime = vim.loop.hrtime
    profile_info = {}
    time = function(chunk, start)
      if start then
        profile_info[chunk] = hrtime()
      else
        profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
      end
    end
  else
    time = function(chunk, start) end
  end
  
local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end

  _G._packer = _G._packer or {}
  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/Users/mattkubej/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?.lua;/Users/mattkubej/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?/init.lua;/Users/mattkubej/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?.lua;/Users/mattkubej/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/Users/mattkubej/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s))
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  ["editorconfig-vim"] = {
    loaded = true,
    path = "/Users/mattkubej/.local/share/nvim/site/pack/packer/start/editorconfig-vim"
  },
  ["emmet-vim"] = {
    loaded = true,
    path = "/Users/mattkubej/.local/share/nvim/site/pack/packer/start/emmet-vim"
  },
  ["formatter.nvim"] = {
    config = { "require('mk.plugins.configs.formatter')" },
    loaded = true,
    path = "/Users/mattkubej/.local/share/nvim/site/pack/packer/start/formatter.nvim"
  },
  fzf = {
    loaded = true,
    path = "/Users/mattkubej/.local/share/nvim/site/pack/packer/start/fzf"
  },
  ["fzf.vim"] = {
    loaded = true,
    path = "/Users/mattkubej/.local/share/nvim/site/pack/packer/start/fzf.vim"
  },
  ["gitsigns.nvim"] = {
    config = { "require('mk.plugins.configs.gitsigns')" },
    loaded = true,
    path = "/Users/mattkubej/.local/share/nvim/site/pack/packer/start/gitsigns.nvim"
  },
  ["gruvbox-flat.nvim"] = {
    config = { "require('mk.plugins.configs.gruvbox-flat')" },
    loaded = true,
    path = "/Users/mattkubej/.local/share/nvim/site/pack/packer/start/gruvbox-flat.nvim"
  },
  ["gv.vim"] = {
    loaded = true,
    path = "/Users/mattkubej/.local/share/nvim/site/pack/packer/start/gv.vim"
  },
  ["jest.nvim"] = {
    loaded = true,
    path = "/Users/mattkubej/.local/share/nvim/site/pack/packer/start/jest.nvim"
  },
  ["lualine.nvim"] = {
    config = { "require('mk.plugins.configs.lualine')" },
    loaded = true,
    path = "/Users/mattkubej/.local/share/nvim/site/pack/packer/start/lualine.nvim"
  },
  nerdcommenter = {
    config = { "require('mk.plugins.configs.nerdtree')" },
    loaded = true,
    path = "/Users/mattkubej/.local/share/nvim/site/pack/packer/start/nerdcommenter"
  },
  nerdtree = {
    loaded = true,
    path = "/Users/mattkubej/.local/share/nvim/site/pack/packer/start/nerdtree"
  },
  ["nvim-compe"] = {
    config = { 'require("mk.plugins.configs.compe")' },
    loaded = true,
    path = "/Users/mattkubej/.local/share/nvim/site/pack/packer/start/nvim-compe"
  },
  ["nvim-lspconfig"] = {
    config = { 'require("mk.plugins.configs.lsp")' },
    loaded = true,
    path = "/Users/mattkubej/.local/share/nvim/site/pack/packer/start/nvim-lspconfig"
  },
  ["nvim-treesitter"] = {
    config = { "require('mk.plugins.configs.treesitter')" },
    loaded = true,
    path = "/Users/mattkubej/.local/share/nvim/site/pack/packer/start/nvim-treesitter"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/Users/mattkubej/.local/share/nvim/site/pack/packer/start/packer.nvim"
  },
  playground = {
    loaded = true,
    path = "/Users/mattkubej/.local/share/nvim/site/pack/packer/start/playground"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/Users/mattkubej/.local/share/nvim/site/pack/packer/start/plenary.nvim"
  },
  ["popup.nvim"] = {
    loaded = true,
    path = "/Users/mattkubej/.local/share/nvim/site/pack/packer/start/popup.nvim"
  },
  ["telescope.nvim"] = {
    config = { "require('mk.plugins.configs.telescope')" },
    loaded = true,
    path = "/Users/mattkubej/.local/share/nvim/site/pack/packer/start/telescope.nvim"
  },
  ["vim-easy-align"] = {
    config = { "require('mk.plugins.configs.easyalign')" },
    loaded = true,
    path = "/Users/mattkubej/.local/share/nvim/site/pack/packer/start/vim-easy-align"
  },
  ["vim-fish"] = {
    loaded = true,
    path = "/Users/mattkubej/.local/share/nvim/site/pack/packer/start/vim-fish"
  },
  ["vim-fugitive"] = {
    loaded = true,
    path = "/Users/mattkubej/.local/share/nvim/site/pack/packer/start/vim-fugitive"
  },
  ["vim-go"] = {
    loaded = true,
    path = "/Users/mattkubej/.local/share/nvim/site/pack/packer/start/vim-go"
  },
  ["vim-mdx-js"] = {
    loaded = true,
    path = "/Users/mattkubej/.local/share/nvim/site/pack/packer/start/vim-mdx-js"
  },
  ["vim-surround"] = {
    loaded = true,
    path = "/Users/mattkubej/.local/share/nvim/site/pack/packer/start/vim-surround"
  },
  ["vim-tmux-navigator"] = {
    loaded = true,
    path = "/Users/mattkubej/.local/share/nvim/site/pack/packer/start/vim-tmux-navigator"
  },
  ["vim-unimpaired"] = {
    loaded = true,
    path = "/Users/mattkubej/.local/share/nvim/site/pack/packer/start/vim-unimpaired"
  },
  vimwiki = {
    config = { "require('mk.plugins.configs.vimwiki')" },
    loaded = true,
    path = "/Users/mattkubej/.local/share/nvim/site/pack/packer/start/vimwiki"
  }
}

time([[Defining packer_plugins]], false)
-- Config for: lualine.nvim
time([[Config for lualine.nvim]], true)
require('mk.plugins.configs.lualine')
time([[Config for lualine.nvim]], false)
-- Config for: formatter.nvim
time([[Config for formatter.nvim]], true)
require('mk.plugins.configs.formatter')
time([[Config for formatter.nvim]], false)
-- Config for: telescope.nvim
time([[Config for telescope.nvim]], true)
require('mk.plugins.configs.telescope')
time([[Config for telescope.nvim]], false)
-- Config for: vimwiki
time([[Config for vimwiki]], true)
require('mk.plugins.configs.vimwiki')
time([[Config for vimwiki]], false)
-- Config for: nvim-compe
time([[Config for nvim-compe]], true)
require("mk.plugins.configs.compe")
time([[Config for nvim-compe]], false)
-- Config for: gruvbox-flat.nvim
time([[Config for gruvbox-flat.nvim]], true)
require('mk.plugins.configs.gruvbox-flat')
time([[Config for gruvbox-flat.nvim]], false)
-- Config for: nvim-lspconfig
time([[Config for nvim-lspconfig]], true)
require("mk.plugins.configs.lsp")
time([[Config for nvim-lspconfig]], false)
-- Config for: gitsigns.nvim
time([[Config for gitsigns.nvim]], true)
require('mk.plugins.configs.gitsigns')
time([[Config for gitsigns.nvim]], false)
-- Config for: nvim-treesitter
time([[Config for nvim-treesitter]], true)
require('mk.plugins.configs.treesitter')
time([[Config for nvim-treesitter]], false)
-- Config for: vim-easy-align
time([[Config for vim-easy-align]], true)
require('mk.plugins.configs.easyalign')
time([[Config for vim-easy-align]], false)
-- Config for: nerdcommenter
time([[Config for nerdcommenter]], true)
require('mk.plugins.configs.nerdtree')
time([[Config for nerdcommenter]], false)
if should_profile then save_profiles() end

end)

if not no_errors then
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
