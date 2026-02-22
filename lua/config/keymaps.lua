-- Set leader key to space
vim.g.mapleader = " "

-- nvim-tree toggle
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true })

-- Half-page scrolling with centered cursor
vim.keymap.set('n', '<C-d>', '<C-d>zz0')
vim.keymap.set('n', '<C-u>', '<C-u>zz0')

-- Keep search results centered
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

-- Jumping between tab stops for snippets (works for .tex, .py, anything)
vim.keymap.set({ "i", "s" }, "<C-j>", function()
  require("luasnip").jump(1)
end, { silent = true })

vim.keymap.set({ "i", "s" }, "<C-k>", function()
  require("luasnip").jump(-1)
end, { silent = true })

-- Jump past closing delimiter
vim.keymap.set("i", "<C-l>", function()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local line = vim.api.nvim_get_current_line()
  local char = line:sub(col + 1, col + 1)
  if char:match("[%)%]%}%$>\"']") then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Right>", true, false, true), "n", false)
  end
end, { silent = true })
