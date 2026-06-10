-- VimTeX: plugin and configs
return {
  "lervag/vimtex",
  lazy = false,
  init = function()
    if vim.fn.has("mac") == 1 then
      vim.g.vimtex_view_method = "general"
      vim.g.vimtex_view_general_viewer = "displayline"
      vim.g.vimtex_view_general_options = "-r @line @pdf @tex"
    -- else
      -- vim.g.vimtex_view_method = "okular"
    else
      vim.fn.serverstart("/tmp/nvim")
      vim.g.vimtex_view_method = "general"
      vim.g.vimtex_view_general_viewer = "okular"
      vim.g.vimtex_view_general_options = "--unique file:@pdf\\#src:@line@tex"
    -- end
    end
    vim.g.vimtex_compiler_method = "latexmk"
    vim.g.vimtex_compiler_latexmk = {
      build_dir = "",
      callback = 1,
      continuous = 1,
      executable = "latexmk",
      options = {
        "-pdf",
        "-pdflatex=pdflatex",
        "-verbose",
        "-file-line-error",
        "-synctex=1",
        "-interaction=nonstopmode",
      },
    }
    vim.g.vimtex_quickfix_mode = 0
  end,
}
