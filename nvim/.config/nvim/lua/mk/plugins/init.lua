-- packer bootstrapping (packer)
if require('mk.plugins.bootstrap')() then
  return
end

require('mk.plugins.startup')

