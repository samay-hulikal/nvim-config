-- mini.surround: plugin and configs
return {
  "echasnovski/mini.surround",
  event = "VeryLazy",
  config = function()
    require("mini.surround").setup()
  end,
}
