local typescript_snips = require("mk.plugins.configs.cmp.snips.typescript")

local snips = {}

for k, v in pairs(typescript_snips) do
  snips[k] = v
end

return snips
