-- treesitter: plugin and configs
return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup({
      install_dir = vim.fn.stdpath("data") .. "/site",
    })
    
    -- Install parsers synchronously on first run; add languages here
    require("nvim-treesitter").install({ "python", "lua", "latex", "vim", "vimdoc" }):wait(300000)
  end,
}
