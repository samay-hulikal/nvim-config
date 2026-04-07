-- nvim-surround: plugin and configs
return {
  "kylechui/nvim-surround",
  version = "^4.0.0",
  event = "VeryLazy",
  config = function()
    require("nvim-surround").setup()
  end,
}
