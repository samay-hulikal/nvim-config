-- Set leader key to space
vim.g.mapleader = " "

-- nvim-tree toggle
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true })

-- Half-page scrolling with centered cursor
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')

-- Keep search results centered
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')
