vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "*.tex",
  callback = function()
    local template_dir = vim.fn.expand("~/.config/nvim/templates/")
    local files = vim.fn.glob(template_dir .. "*.tex", false, true)

    if #files == 0 then return end

    local names = {}
    for _, f in ipairs(files) do
      table.insert(names, vim.fn.fnamemodify(f, ":t:r"))
    end

    vim.ui.select(names, { prompt = "Choose template (Esc to skip):" }, function(choice)
      if choice then
        vim.cmd("0r " .. template_dir .. choice .. ".tex")
      end
    end)
  end,
})
