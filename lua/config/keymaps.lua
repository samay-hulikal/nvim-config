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
