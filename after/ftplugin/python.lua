-- Run current Python script in Rhino 8 with <leader>rr
vim.keymap.set("n", "<leader>rr", function()
  vim.cmd("write")
  local file = vim.fn.expand("%:p")
  local tmpfile = "/tmp/rhino_run.py" -- Copies it to /tmp (this directory is cleared on reboot!)
  vim.fn.system({ "cp", file, tmpfile })
  vim.fn.jobstart(
    { "rhinocode", "script", tmpfile },
    {
      on_stderr = function(_, data)
        if data and data[1] ~= "" then
          vim.notify(table.concat(data, "\n"), vim.log.levels.ERROR)
        end
      end,
      on_exit = function(_, code)
        if code == 0 then
          vim.notify("Script sent to Rhino", vim.log.levels.INFO)
        end
      end,
    }
  )
end, { buffer = true, desc = "Run in Rhino" })
