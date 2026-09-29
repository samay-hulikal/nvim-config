-- Route yanks to the local terminal's clipboard via OSC 52, only over SSH.
if not (vim.env.SSH_TTY or vim.env.SSH_CONNECTION) then
  return
end

local ok, osc52 = pcall(require, "vim.ui.clipboard.osc52")
if not ok then
  return -- Neovim < 0.10: do nothing
end

local function paste()
  return { vim.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
end

vim.g.clipboard = {
  name = "OSC 52",
  copy  = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
  paste = { ["+"] = paste,           ["*"] = paste },
}
