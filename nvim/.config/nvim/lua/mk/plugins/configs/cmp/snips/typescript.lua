local ls = require "luasnip"

local sn = ls.sn
local i = ls.insert_node
local t = ls.text_node
local c = ls.choice_node

return {
  cl = {
    t "console.log(" ,
    c(1, {
      i(0),
      sn(nil, {
        t "{ ",
        i(1, "variable"),
        t " }",
      }),
    }),
    t ");" ,
  },

  af = {
    t "const " ,
    i(1, "var"),
    t " = (" ,
    i(2),
    t {") => {", "\t"} ,
    i(0),
    t {"", "};"} ;
  },
}
