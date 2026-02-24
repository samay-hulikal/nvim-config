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
]]--

return {
  -- Inserting a figure
  s("begfig",{
    t({"\\begin{figure}[tb]", "\t"}),
    t("\\includegraphics{"), i(1), t({"}", "\t"}),
    t("\\caption{"), i(2), t({"}", "\t"}),
    t("\\label{fig:"), i(3), t({"}", "\\end{figure}"}),
  }),

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
  
  -- Environment: begeq → \begin{equation} ... \end{equation}
  s("begeq", {
    t("\\begin{equation}\\label{eq:"), i(1), t({ "}", "\t" }),
    i(2),
    t({ "", "\\end{equation}" }),
  }),

  -- Fraction: ff → \frac{}{}
  s("ff", {
    t("\\frac{"), i(1), t("}{"), i(2), t("}"), 
  }),

  -- Summation: sum -> \sum_{}^{} 
  s("sum", {
    t("\\sum_{"), i(1), t("}^{"), i(2), t("}"), 
  }),

  -- Integration: intt -> \intt_{}^{} 
  s("intt", {
    t("\\int_{"), i(1), t("}^{"), i(2), t("}"), 
  }),

  -- Powers or superscripts: rd -> ^{}
  s("rd", {
    t("^{"), i(1), t("}"), 
  }),

  -- Subscripts: _ -> _{}
  s("_", {
    t("_{"), i(1), t("}"), 
  }),

  -- Inserting text: txt -> \text{}
  s("txt", {
    t("\\text{"), i(1), t("}"),
  }),

  -- Inserting bar: bar -> \bar{}
  s("bar", {
    t("\\bar{"), i(1), t("}"),
  }),

  -- Inserting hat: hat -> \hat{}
  s("hat", {
    t("\\hat{"), i(1), t("}"),
  }),

  -- Inserting dot: dot -> \dot{}
  s("dot", {
    t("\\dot{"), i(1), t("}"),
  }),

  -- Inserting ddot: ddot -> \dot{}
  s("ddot", {
    t("\\ddot{"), i(1), t("}"),
  }),

  -- Inserting bigger parentheses: lr( -> \left(\right)
  s("lr0", {
    t("\\left("), i(1), t("\\right)"),
  }),

  -- Math fonts: mbf -> \bm{}
  s("mbf", {
    t("\\bm{"), i(1), t("}"),
  }),

  -- Math fonts: mcal -> \mathcal{}
  s("mcal", {
    t("\\mathcal{"), i(1), t("}"),
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
  s("@k", { t("\\kappa") }),
  s("@z", { t("\\zeta") })
}
