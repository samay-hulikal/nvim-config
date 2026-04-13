-- harpoon: quick file navigation with telescope UI
return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    local harpoon = require("harpoon")

    -- REQUIRED
    harpoon:setup()

    -- Telescope integration
    local conf = require("telescope.config").values
    local function toggle_telescope(harpoon_files)
      local file_paths = {}
      for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
      end

      require("telescope.pickers").new({}, {
        prompt_title = "Harpoon",
        finder = require("telescope.finders").new_table({
          results = file_paths,
        }),
        previewer = conf.file_previewer({}),
        sorter = conf.generic_sorter({}),
      }):find()
    end

    -- Add file to harpoon list
    vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end, { desc = "Harpoon: add file" })

    -- Toggle telescope menu
    vim.keymap.set("n", "<C-p>", function() toggle_telescope(harpoon:list()) end, { desc = "Harpoon: telescope menu" })

    -- Quick jump to files 1-4
    vim.keymap.set("n", "<C-j>", function() harpoon:list():select(1) end, { desc = "Harpoon: file 1" })
    vim.keymap.set("n", "<C-k>", function() harpoon:list():select(2) end, { desc = "Harpoon: file 2" })
    vim.keymap.set("n", "<C-l>", function() harpoon:list():select(3) end, { desc = "Harpoon: file 3" })
    vim.keymap.set("n", "<C-;>", function() harpoon:list():select(4) end, { desc = "Harpoon: file 4" })

    -- Cycle through harpoon list
    vim.keymap.set("n", "[h", function() harpoon:list():prev() end)
    vim.keymap.set("n", "]h", function() harpoon:list():next() end)
  end,
}
