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
    config = { "\27LJ\2\n<\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0!mk.plugins.configs.formatter\frequire\0" },
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
    config = { "\27LJ\2\n;\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0 mk.plugins.configs.gitsigns\frequire\0" },
    loaded = true,
    path = "/Users/mattkubej/.local/share/nvim/site/pack/packer/start/gitsigns.nvim"
  },
  ["gruvbox-flat.nvim"] = {
    config = { "\27LJ\2\n?\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0$mk.plugins.configs.gruvbox-flat\frequire\0" },
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
    config = { "\27LJ\2\n:\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\31mk.plugins.configs.lualine\frequire\0" },
    loaded = true,
    path = "/Users/mattkubej/.local/share/nvim/site/pack/packer/start/lualine.nvim"
  },
  nerdcommenter = {
    config = { "\27LJ\2\n;\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0 mk.plugins.configs.nerdtree\frequire\0" },
    loaded = true,
    path = "/Users/mattkubej/.local/share/nvim/site/pack/packer/start/nerdcommenter"
  },
  nerdtree = {
    loaded = true,
    path = "/Users/mattkubej/.local/share/nvim/site/pack/packer/start/nerdtree"
  },
  ["nvim-compe"] = {
    config = { "\27LJ\2\n8\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\29mk.plugins.configs.compe\frequire\0" },
    loaded = true,
    path = "/Users/mattkubej/.local/share/nvim/site/pack/packer/start/nvim-compe"
  },
  ["nvim-lspconfig"] = {
    config = { "\27LJ\2\n6\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\27mk.plugins.configs.lsp\frequire\0" },
    loaded = true,
    path = "/Users/mattkubej/.local/share/nvim/site/pack/packer/start/nvim-lspconfig"
  },
  ["nvim-treesitter"] = {
    config = { "\27LJ\2\n=\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\"mk.plugins.configs.treesitter\frequire\0" },
    loaded = true,
    path = "/Users/mattkubej/.local/share/nvim/site/pack/packer/start/nvim-treesitter"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/Users/mattkubej/.local/share/nvim/site/pack/packer/start/packer.nvim"
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
    config = { "\27LJ\2\n<\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0!mk.plugins.configs.telescope\frequire\0" },
    loaded = true,
    path = "/Users/mattkubej/.local/share/nvim/site/pack/packer/start/telescope.nvim"
  },
  ["vim-easy-align"] = {
    config = { "\27LJ\2\n<\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0!mk.plugins.configs.easyalign\frequire\0" },
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
    config = { "\27LJ\2\n:\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\31mk.plugins.configs.vimwiki\frequire\0" },
    loaded = true,
    path = "/Users/mattkubej/.local/share/nvim/site/pack/packer/start/vimwiki"
  }
}

time([[Defining packer_plugins]], false)
-- Config for: gitsigns.nvim
time([[Config for gitsigns.nvim]], true)
try_loadstring("\27LJ\2\n;\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0 mk.plugins.configs.gitsigns\frequire\0", "config", "gitsigns.nvim")
time([[Config for gitsigns.nvim]], false)
-- Config for: nvim-compe
time([[Config for nvim-compe]], true)
try_loadstring("\27LJ\2\n8\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\29mk.plugins.configs.compe\frequire\0", "config", "nvim-compe")
time([[Config for nvim-compe]], false)
-- Config for: vim-easy-align
time([[Config for vim-easy-align]], true)
try_loadstring("\27LJ\2\n<\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0!mk.plugins.configs.easyalign\frequire\0", "config", "vim-easy-align")
time([[Config for vim-easy-align]], false)
-- Config for: nvim-lspconfig
time([[Config for nvim-lspconfig]], true)
try_loadstring("\27LJ\2\n6\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\27mk.plugins.configs.lsp\frequire\0", "config", "nvim-lspconfig")
time([[Config for nvim-lspconfig]], false)
-- Config for: nvim-treesitter
time([[Config for nvim-treesitter]], true)
try_loadstring("\27LJ\2\n=\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\"mk.plugins.configs.treesitter\frequire\0", "config", "nvim-treesitter")
time([[Config for nvim-treesitter]], false)
-- Config for: formatter.nvim
time([[Config for formatter.nvim]], true)
try_loadstring("\27LJ\2\n<\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0!mk.plugins.configs.formatter\frequire\0", "config", "formatter.nvim")
time([[Config for formatter.nvim]], false)
-- Config for: lualine.nvim
time([[Config for lualine.nvim]], true)
try_loadstring("\27LJ\2\n:\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\31mk.plugins.configs.lualine\frequire\0", "config", "lualine.nvim")
time([[Config for lualine.nvim]], false)
-- Config for: telescope.nvim
time([[Config for telescope.nvim]], true)
try_loadstring("\27LJ\2\n<\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0!mk.plugins.configs.telescope\frequire\0", "config", "telescope.nvim")
time([[Config for telescope.nvim]], false)
-- Config for: vimwiki
time([[Config for vimwiki]], true)
try_loadstring("\27LJ\2\n:\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0\31mk.plugins.configs.vimwiki\frequire\0", "config", "vimwiki")
time([[Config for vimwiki]], false)
-- Config for: nerdcommenter
time([[Config for nerdcommenter]], true)
try_loadstring("\27LJ\2\n;\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0 mk.plugins.configs.nerdtree\frequire\0", "config", "nerdcommenter")
time([[Config for nerdcommenter]], false)
-- Config for: gruvbox-flat.nvim
time([[Config for gruvbox-flat.nvim]], true)
try_loadstring("\27LJ\2\n?\0\0\3\0\2\0\0046\0\0\0'\2\1\0B\0\2\1K\0\1\0$mk.plugins.configs.gruvbox-flat\frequire\0", "config", "gruvbox-flat.nvim")
time([[Config for gruvbox-flat.nvim]], false)
if should_profile then save_profiles() end

end)

if not no_errors then
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
