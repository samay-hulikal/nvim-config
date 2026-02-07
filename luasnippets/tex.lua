local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local rep = require("luasnip.extras").rep

--[[
s("trigger", {
  t("static text"),      -- text_node: literal text
  i(1, "placeholder"),   -- insert_node: tab stop with optional default
  t(" more text "),
  i(2),                  -- another tab stop
  rep(1),                -- repeats whatever you typed in i(1)
})

--]]

return {
  -- Inline math: mk → $|$
  s("mk", {
    t("$"), i(1), t("$"),
  }),

  -- Display math: dm → \[ ... \]
  s("dm", {
    t({ "\\[", "\t" }), i(1), t({ "", "\\]" }),
  }),

  -- Environment: beg → \begin{env} ... \end{env}
  s("beg", {
    t("\\begin{"), i(1, "env"), t({ "}", "\t" }),
    i(2),
    t({ "", "\\end{" }), rep(1), t("}"),
  }),

  -- Fraction: ff → \frac{}{}
  s("ff", {
    t("\\frac{"), i(1), t("}{"), i(2), t("}"),
  }),

  -- Greek letters
  s("@a", { t("\\alpha") }),
  s("@b", { t("\\beta") }),
  s("@g", { t("\\gamma") }),
  s("@d", { t("\\delta") }),
  s("@e", { t("\\epsilon") }),
  s("@o", { t("\\omega") }),
  s("@l", { t("\\lambda") }),
  s("@m", { t("\\mu") }),
  s("@p", { t("\\pi") }),
  s("@s", { t("\\sigma") }),
  s("@z", { t("\\zeta") })
}
