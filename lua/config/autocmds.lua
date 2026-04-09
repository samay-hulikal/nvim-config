-- Allows you to select a template for a fresh .tex file
vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "*.tex",
  callback = function()
    vim.defer_fn(function()
      local template_dir = vim.fn.expand("~/.config/nvim/templates/")
      local files = vim.fn.glob(template_dir .. "*.tex", false, true)
      if #files == 0 then return end

      local pickers = require("telescope.pickers")
      local finders = require("telescope.finders")
      local conf = require("telescope.config").values
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      local names = {}
      for _, f in ipairs(files) do
        table.insert(names, vim.fn.fnamemodify(f, ":t:r"))
      end

      pickers.new({}, {
        prompt_title = "Choose Template",
        finder = finders.new_table({ results = names }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            if selection then
              vim.cmd("0r " .. template_dir .. selection[1] .. ".tex")
            end
          end)
          return true
        end,
      }):find()
    end, 50)
  end,
})

-- Enabling treesitter highlighting
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python", "lua", "vim"},
  callback = function()
    vim.treesitter.start()
  end,
})
