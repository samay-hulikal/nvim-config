-- mini.tabline: plugin and configs
return {
  "echasnovski/mini.tabline",
  version = false,
  event = "VeryLazy",
  config = function()
    require("mini.tabline").setup()
  end,
}
