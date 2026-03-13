-- todo-comments: plugins and configs
return {
  "folke/todo-comments.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  event = { "BufReadPre", "BufNewFile" },
  keys = {
    { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Find TODOs" },
  },
  opts = {},
}
