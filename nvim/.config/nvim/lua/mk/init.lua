-- global functions must load first
require('mk.globals')

-- neovim options
require('mk.options')

-- packer bootstrapping (packer)
if require('mk.bootstrap')() then
  return
end

--load plugins
require('mk.plugins')

-- load keymaps
require("mk.keymaps")
