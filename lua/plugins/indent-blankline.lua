-- indent-blankline: plugin and configs
return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  config = function()
    require("ibl").setup()
  end,
}
-- return {
--   "lukas-reineke/indent-blankline.nvim",
--   main = "ibl",
--   event = { "BufReadPre", "BufNewFile" },
--   config = function()
--     require("ibl").setup({
--       indent = { char = "│" },
--       scope = {
--         enabled = true,
--         show_start = true,
--         show_end = false,
--       },
--     })
--   end,
-- }
