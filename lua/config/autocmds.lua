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

-- Obsidian sync stuff
vim.api.nvim_create_autocmd("User", {
  pattern = "VimtexEventCompileSuccess",
  callback = function()
    local pdf = vim.fn.expand("%:p"):gsub("%.tex$", ".pdf")
    local vault_attach = os.getenv("HOME") .. "/Desktop/Obsidian Vaults/Samay's Vault/File Attachments"
    local link_name = vim.fn.fnamemodify(pdf, ":h:t") .. ".pdf"
    local link_path = vault_attach .. "/" .. link_name
    if vim.fn.filereadable(link_path) == 1 or vim.fn.getftype(link_path) == "link" then
      vim.fn.system({ "ln", "-sf", pdf, link_path })
      vim.defer_fn(function()
        vim.notify("Obsidian sync nudged: " .. link_name, vim.log.levels.INFO)
      end, 5000)
    end
  end,
})

vim.api.nvim_create_user_command("ObsidianLink", function(opts)
  local pdf = vim.fn.expand("%:p"):gsub("%.tex$", ".pdf")
  if vim.fn.filereadable(pdf) == 0 then
    vim.notify("No PDF found. Compile first.", vim.log.levels.WARN)
    return
  end
  local vault_attach = os.getenv("HOME") .. "/Desktop/Obsidian Vaults/Samay's Vault/File Attachments"
  local link_name = (opts.args ~= "" and opts.args or vim.fn.fnamemodify(pdf, ":h:t")) .. ".pdf"
  local link_path = vault_attach .. "/" .. link_name
  vim.fn.system({ "ln", "-sf", pdf, link_path })
  vim.notify("Linked: " .. link_name, vim.log.levels.INFO)
end, { nargs = "?" })
