-- Use general viewer method with displayline
vim.g.vimtex_view_method = 'general'
vim.g.vimtex_view_general_viewer = 'displayline'
vim.g.vimtex_view_general_options = '-r @line @pdf @tex'

-- Use latexmk but configure it to use pdflatex
vim.g.vimtex_compiler_method = 'latexmk'
vim.g.vimtex_compiler_latexmk = {
  build_dir = '',
  callback = 1,
  continuous = 1,
  executable = 'latexmk',
  options = {
    '-pdf',
    '-pdflatex=pdflatex',
    '-verbose',
    '-file-line-error',
    '-synctex=1',
    '-interaction=nonstopmode',
  },
}

-- Don't open quickfix window automatically on warnings
vim.g.vimtex_quickfix_mode = 0

-- Enable forward search (source -> PDF)
vim.g.vimtex_view_skim_sync = 1
vim.g.vimtex_view_skim_activate = 1
