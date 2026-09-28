-- zcite.lua — search Zotero from Neovim, insert \zcite{label}{key}, append BibTeX to refs.bib
-- Requires: Zotero running + Better BibTeX, curl, Neovim >= 0.10
-- Put in ~/.config/nvim/lua/zcite.lua

local M = {}

M.config = {
  url = "http://127.0.0.1:23119/better-bibtex/json-rpc",
  bib_name = "refs.bib",          -- fallback if no \bibliography{} / \addbibresource{} found
  translator = "Better BibTeX",   -- or "Better BibLaTeX"
  min_chars = 2,                  -- start querying Zotero after this many characters
  debounce = 150,                 -- ms to wait after a keystroke before querying
  max_results = 100,
  -- Zotero quick-search mode: "titleCreatorYear" (title, authors, year — like Zotero's search box),
  -- "fields" (all fields incl. abstract, journal, tags) or "everything" (also PDF full text; slower)
  search_mode = "titleCreatorYear",
  -- text shown in \textsf{...}; receives a CSL-JSON item
  -- text for the first slot of \zcite. false = leave it empty and put you there in insert mode.
  -- Or a function(item) returning a string (receives a CSL-JSON item), e.g. M.author_year
  label = false,
}

function M.author_year(item)
  local a = item.author and item.author[1]
  local name = a and (a.family or a.literal) or "Anon"
  if item.author and #item.author > 2 then
    name = name .. " et al."
  elseif item.author and #item.author == 2 then
    local b = item.author[2]
    name = name .. " & " .. (b.family or b.literal or "")
  end
  local y = M.year(item)
  return y and (name .. " " .. y) or name
end

local function notify(msg, level)
  vim.notify("zcite: " .. msg, level or vim.log.levels.INFO)
end

function M.year(item)
  local dp = item.issued and item.issued["date-parts"]
  return dp and dp[1] and dp[1][1] and tostring(dp[1][1]) or nil
end

local function citekey(item)
  local k = item.citekey or item["citation-key"] or item.citationKey
  return (k ~= nil and k ~= "") and k or nil
end

-- Better BibTeX's plain-string search skips authors, so pass Zotero's own
-- quick-search condition instead (splits into words; every word must match)
local function search_params(q)
  return { {
    { "quicksearch-" .. M.config.search_mode, "contains", q },
    { "ignore_feeds" },
  } }
end

local function has_key(it) return citekey(it) ~= nil end

local function tex_escape(s)
  return (s:gsub("([%%#_&])", "\\%1"))
end

-- JSON-RPC to Better BibTeX -------------------------------------------------

local function rpc_cmd(method, params)
  local body = vim.json.encode({ jsonrpc = "2.0", method = method, params = params })
  local cmd = {
    "curl", "-sS", "--max-time", "5", "-X", "POST",
    "-H", "Content-Type: application/json",
    "-H", "Accept: application/json",
    "--data-binary", "@-", M.config.url,
  }
  return cmd, body
end

local function rpc_decode(res)
  if res.code ~= 0 then
    return nil, "can't reach Zotero (running, with Better BibTeX?) " .. (res.stderr or "")
  end
  local ok, dec = pcall(vim.json.decode, res.stdout, { luanil = { object = true, array = true } })
  if not ok or type(dec) ~= "table" then
    return nil, "unexpected response: " .. tostring(res.stdout)
  end
  if dec.error then
    return nil, dec.error.message or vim.inspect(dec.error)
  end
  return dec.result
end

-- async
local function rpc(method, params, cb)
  local cmd, body = rpc_cmd(method, params)
  vim.system(cmd, { stdin = body, text = true }, function(res)
    vim.schedule(function() cb(rpc_decode(res)) end)
  end)
end

-- blocking (used by the live Telescope finder; local server answers in ms)
local function rpc_sync(method, params)
  local cmd, body = rpc_cmd(method, params)
  local ok, res = pcall(function()
    return vim.system(cmd, { stdin = body, text = true }):wait(6000)
  end)
  if not ok then return nil, tostring(res) end
  return rpc_decode(res)
end

-- locate the .bib file: \addbibresource / \bibliography in the buffer, else refs.bib upward, else create next to file
local function find_bib(buf)
  local file = vim.api.nvim_buf_get_name(buf)
  local dir = vim.fs.dirname(file)
  for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    local name = line:match("^[^%%]*\\addbibresource%s*{([^}]+)}")
      or line:match("^[^%%]*\\bibliography%s*{([^},]+)")
    if name then
      name = vim.trim(name)
      if not name:match("%.bib$") then name = name .. ".bib" end
      return vim.fs.normalize(name:sub(1, 1) == "/" and name or vim.fs.joinpath(dir, name))
    end
  end
  local found = vim.fs.find(M.config.bib_name, { upward = true, path = dir, stop = vim.env.HOME })[1]
  return found or vim.fs.joinpath(dir, M.config.bib_name)
end

local function bib_has_key(path, key)
  local f = io.open(path, "r")
  if not f then return false end
  local content = f:read("*a")
  f:close()
  return content:find("@%w+%s*{%s*" .. vim.pesc(key) .. "%s*,") ~= nil
end

local function append_bib(path, key, cb)
  if bib_has_key(path, key) then return cb(false) end
  rpc("item.export", { { key }, M.config.translator }, function(res, err)
    if err then return notify("export failed: " .. err, vim.log.levels.ERROR) end
    -- older BBT versions return {status, content-type, body}
    local bib = type(res) == "table" and res[3] or res
    if type(bib) ~= "string" or bib == "" then
      return notify("empty BibTeX export for " .. key, vim.log.levels.ERROR)
    end
    local f, ioerr = io.open(path, "a")
    if not f then return notify("can't write " .. path .. ": " .. ioerr, vim.log.levels.ERROR) end
    f:write("\n" .. vim.trim(bib) .. "\n")
    f:close()
    cb(true)
  end)
end

-- inserts text after the cursor; `cursor_at` = byte offset in text to leave the cursor on
-- (for insert mode: the character you'll type before). Returns true if it could place the cursor.
local function insert_text(buf, win, pos, text, cursor_at)
  if not vim.api.nvim_buf_is_valid(buf) then return false end
  local row = pos[1] - 1
  local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or ""
  local col = math.min(pos[2] + 1, #line) -- insert after cursor char, like `a`
  if #line == 0 then col = 0 end
  vim.api.nvim_buf_set_text(buf, row, col, row, col, { text })
  if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == buf then
    vim.api.nvim_set_current_win(win)
    vim.api.nvim_win_set_cursor(win, { row + 1, col + (cursor_at or (#text - 1)) })
    return true
  end
  return false
end

local function format_item(item)
  local a = item.author and item.author[1]
  local who = a and (a.family or a.literal) or "?"
  return string.format("%s (%s) — %s  [%s]", who, M.year(item) or "n.d.", item.title or "", citekey(item) or "?")
end

-- insert \zcite and add the entry to the .bib
local function choose(item, buf, win, pos)
  local key = citekey(item)
  local bib = find_bib(buf)
  append_bib(bib, key, function(added)
    notify(added and ("added " .. key .. " to " .. vim.fn.fnamemodify(bib, ":~:."))
      or (key .. " already in " .. vim.fn.fnamemodify(bib, ":~:.")))
  end)

  if type(M.config.label) == "function" then
    insert_text(buf, win, pos, string.format("\\zcite{%s}{%s}", tex_escape(M.config.label(item)), key))
    return
  end
  -- empty first slot: land on the "}" of \zcite{} and start insert mode
  local text = string.format("\\zcite{}{%s}", key)
  if insert_text(buf, win, pos, text, #"\\zcite{") then
    -- after the picker has fully closed: it leaves insert mode on close, which nudges
    -- the cursor one column left and can knock us back to normal mode
    local target = vim.api.nvim_win_get_cursor(win)
    vim.defer_fn(function()
      if not vim.api.nvim_win_is_valid(win) or vim.api.nvim_win_get_buf(win) ~= buf then return end
      vim.api.nvim_set_current_win(win)
      vim.api.nvim_win_set_cursor(win, target)
      vim.cmd("startinsert")
    end, 20)
  end
end

-- simple prompt + vim.ui.select flow (fallback, and :Zcite <query>)
function M.pick(query)
  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  local pos = vim.api.nvim_win_get_cursor(win)

  local function search(q)
    if not q or vim.trim(q) == "" then return end
    rpc("item.search", search_params(q), function(items, err)
      if err then return notify(err, vim.log.levels.ERROR) end
      items = vim.tbl_filter(has_key, items or {})
      if #items == 0 then return notify("no matches for '" .. q .. "'") end
      vim.ui.select(items, { prompt = "Zotero: ", format_item = format_item }, function(item)
        if item then choose(item, buf, win, pos) end
      end)
    end)
  end

  if query then search(query) else vim.ui.input({ prompt = "Zotero search: " }, search) end
end

-- live Telescope picker: Zotero is re-queried as you type ---------------------

local function authors_str(item, max)
  local names = {}
  for i, a in ipairs(item.author or {}) do
    if max and i > max then
      names[#names + 1] = "…"
      break
    end
    names[#names + 1] = a.literal or vim.trim((a.given or "") .. " " .. (a.family or ""))
  end
  return table.concat(names, ", ")
end

local function preview_lines(item)
  local lines = { item.title or "(untitled)", "" }
  local au = authors_str(item, 12)
  if au ~= "" then lines[#lines + 1] = au end
  local venue = item["container-title"] or item.publisher
  local meta = table.concat(vim.tbl_filter(function(s) return s and s ~= "" end, {
    venue, item.volume and ("vol. " .. item.volume), item.page and ("p. " .. item.page), M.year(item),
  }), ", ")
  if meta ~= "" then lines[#lines + 1] = meta end
  if item.DOI then lines[#lines + 1] = "doi:" .. item.DOI end
  lines[#lines + 1] = "key: " .. (citekey(item) or "?")
  if item.abstract and item.abstract ~= "" then
    lines[#lines + 1] = ""
    for _, l in ipairs(vim.split(item.abstract, "\n", { plain = true })) do lines[#lines + 1] = l end
  end
  return lines
end

function M.telescope(opts)
  local has_tel = pcall(require, "telescope")
  if not has_tel then return M.pick() end
  opts = opts or {}

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local sorters = require("telescope.sorters")
  local previewers = require("telescope.previewers")
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local entry_display = require("telescope.pickers.entry_display")

  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  local pos = vim.api.nvim_win_get_cursor(win)

  local displayer = entry_display.create({
    separator = "  ",
    items = { { width = 18 }, { width = 4 }, { remaining = true } },
  })

  local cache, warned = {}, false
  local function query(prompt)
    prompt = vim.trim(prompt or "")
    if #prompt < M.config.min_chars then return {} end
    if cache[prompt] then return cache[prompt] end
    local items, err = rpc_sync("item.search", search_params(prompt))
    if err then
      if not warned then
        warned = true
        vim.schedule(function() notify(err, vim.log.levels.ERROR) end)
      end
      return {}
    end
    items = vim.tbl_filter(has_key, items or {})
    if M.config.max_results and #items > M.config.max_results then
      items = vim.list_slice(items, 1, M.config.max_results)
    end
    cache[prompt] = items
    return items
  end

  pickers.new(opts, {
    prompt_title = "Zotero",
    debounce = M.config.debounce,
    finder = finders.new_dynamic({
      fn = query,
      entry_maker = function(item)
        local a = item.author and item.author[1]
        local who = a and (a.family or a.literal) or "?"
        if item.author and #item.author > 1 then who = who .. " +" end
        local year = M.year(item) or "n.d."
        local title = item.title or ""
        return {
          value = item,
          ordinal = table.concat({ who, year, title, citekey(item) }, " "),
          display = function()
            return displayer({
              { who, "TelescopeResultsIdentifier" },
              { year, "TelescopeResultsNumber" },
              title,
            })
          end,
        }
      end,
    }),
    -- Zotero already did the matching; just highlight what you typed
    sorter = sorters.highlighter_only(opts),
    previewer = previewers.new_buffer_previewer({
      title = "Details",
      define_preview = function(self, entry)
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, preview_lines(entry.value))
        vim.api.nvim_set_option_value("wrap", true, { win = self.state.winid })
        vim.api.nvim_set_option_value("linebreak", true, { win = self.state.winid })
        vim.api.nvim_set_option_value("filetype", "markdown", { buf = self.state.bufnr })
      end,
    }),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local entry = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if entry then choose(entry.value, buf, win, pos) end
      end)
      return true
    end,
  }):find()
end

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "tex", "plaintex" },
    callback = function(ev)
      vim.keymap.set("n", "<leader>zz", function() M.telescope() end,
        { buffer = ev.buf, desc = "Cite from Zotero (\\zcite + refs.bib)" })
    end,
  })
  vim.api.nvim_create_user_command("Zcite", function(a) M.pick(a.args ~= "" and a.args or nil) end, { nargs = "?" })
end

return M
