# Samay's neovim Configuration

A clean, plugin-centric Neovim setup that works across macOS and Linux.

## Requirements

- Neovim 0.11+
- `tree-sitter-cli` (for treesitter parsers)
- C compiler (`gcc`, `clang`, or `c`)
- `tar` and `curl`
- Local tex installation (MacTeX for macOS, TeX Live for Linux)

### macOS
```bash
brew install neovim tree-sitter
```

### Ubuntu
```bash
# Neovim (apt version is too old, use tarball)
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> ~/.bashrc
source ~/.bashrc

# Tree-sitter CLI
sudo apt install npm
sudo npm install -g tree-sitter-cli
```

## Structure

```
~/.config/nvim/
├── yazi/                    # Yazi config; independent of nvim
├── init.lua                 # Entry point: bootstraps lazy.nvim, loads config
├── lua/
│   ├── config/
│   │   ├── options.lua      # Editor settings (line numbers, clipboard, etc.)
│   │   ├── keymaps.lua      # General keybindings
│   │   ├── filetypes.lua    # Per-filetype settings (indentation)
│   │   └── autocmds.lua     # Autocommands (templates, treesitter highlighting)
│   ├── plugins/             # Each file = one plugin (auto-loaded by lazy.nvim)
│   │   ├── colorscheme.lua
│   │   ├── nvim-tree.lua
│   │   ├── vimtex.lua
│   │   ├── lsp.lua
│   │   ├── completion.lua
│   │   ├── autopairs.lua
│   │   ├── telescope.lua
│   │   ├── gitsigns.lua
│   │   ├── lualine.lua
│   │   ├── indent-blankline.lua
│   │   ├── treesitter.lua
│   │   ├── nvim-surround
│   │   ├── mini-tabline.lua
│   │   ├── harpoon2.lua
│   │   └── todo-comments.lua     # Autocommands (templates, treesitter highlighting)
│   └── themes/              # Colorscheme configs (swap by editing colorscheme.lua)
│       ├── rose-pine.lua
│       ├── kanagawa.lua
│       └── tokyonight.lua
├── luasnippets/
│   └── tex.lua              # Custom LaTeX snippets
└── templates/
    └── calculation_template.tex
```

## Installed Plugins

| Plugin | Purpose |
|--------|---------|
| rose-pine/tokyonight/kanagawa | Colorscheme |
| nvim-tree | File explorer |
| vimtex | LaTeX editing and compilation |
| nvim-lspconfig + mason | Language server support |
| nvim-cmp | Autocompletion |
| LuaSnip | Snippets |
| nvim-autopairs | Auto-close brackets/quotes |
| telescope | Fuzzy finder |
| gitsigns | Git status in gutter |
| lualine | Statusline |
| indent-blankline | Indentation guides |
| nvim-treesitter | Syntax highlighting |
| todo-comments | Highlight and search TODO/FIXME/WARN/NOTE |
| nvim-surround | Enclosing characters |
| harpoon | Creates a fast navigable list of your files |
| mini.tabline | Clean tab lines |

## Keybindings

| Key | Action |
|-----|--------|
| `<Space>` | Leader key |
| `<leader>e` | Toggle file explorer |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>fh` | Help tags |
| `<C-d>` | Half-page down (centered) |
| `<C-u>` | Half-page up (centered) |
| `<C-j>` | Snippet jump forward |
| `<C-k>` | Snippet jump backward |
| `<C-l>` | Jump past closing delimiter |
| `gd` | Go to definition (LSP) |
| `K` | Hover info (LSP) |
| `gr` | Find references (LSP) |
| `<leader>rn` | Rename symbol (LSP) |
| `<leader>ft` | Find TODOs in project |

## Adding a New Plugin

1. Create a new file in `lua/plugins/`, e.g., `lua/plugins/myplugin.lua`

2. Add the plugin spec:
```lua
return {
  "author/plugin-name",
  config = function()
    require("plugin-name").setup({
      -- options here
    })
  end,
}
```

3. Restart nvim — lazy.nvim auto-discovers it

### Common Options

```lua
return {
  "author/plugin-name",
  lazy = false,              -- Load immediately (default: lazy-loaded)
  event = "InsertEnter",     -- Load on specific event
  ft = "python",             -- Load for specific filetype
  keys = {                   -- Load when keymap is pressed
    { "<leader>x", "<cmd>DoThing<cr>", desc = "Do thing" },
  },
  dependencies = { "other/plugin" },
  config = function()
    -- Setup code
  end,
}
```

## Changing Colorscheme

1. Edit `lua/plugins/colorscheme.lua`

2. Change the require:
```lua
-- Current
return require("themes.rose-pine")

-- To switch to tokyonight
return require("themes.tokyonight")

-- To switch to kanagawa
return require("themes.kanagawa")
```

3. Restart nvim

### Adding a New Theme

1. Create `lua/themes/mytheme.lua`:
```lua
return {
  "author/mytheme.nvim",
  name = "mytheme",
  priority = 1000,
  config = function()
    require("mytheme").setup({
      -- theme options
    })
    vim.cmd("colorscheme mytheme")
  end,
}
```

2. Update `lua/plugins/colorscheme.lua`:
```lua
return require("themes.mytheme")
```

## VimTeX Setup

### macOS (Skim)
Configure Skim → Preferences → Sync:
- **Command**: `/opt/homebrew/bin/nvim`
- **Arguments**: `--headless -c "VimtexInverseSearch %line '%file'"`

### Linux
Zathura works automatically — no configuration needed.

## Treesitter

Parsers are installed on first launch for: `python`, `lua`, `latex`, `vim`, `vimdoc`

To add more parsers, edit `lua/plugins/treesitter.lua`:
```lua
require("nvim-treesitter").install({ "python", "lua", "latex", "vim", "vimdoc", "rust", "javascript" }):wait(300000)
```

To add highlighting for new languages, edit `lua/config/autocmds.lua`:
```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python", "lua", "vim", "rust", "javascript" },
  callback = function()
    vim.treesitter.start()
  end,
})
```
## Adding LSP for More Languages

Edit `lua/plugins/lsp.lua`:

**1. Add the server to `ensure_installed`:**
```lua
require("mason-lspconfig").setup({
  ensure_installed = { "pyright", "lua_ls", "rust_analyzer" },  -- add here
})
```

**2. Add the server config:**
```lua
vim.lsp.config.lua_ls = {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".git" },
}
```

**3. Enable it for the filetype:**
```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    vim.lsp.enable("lua_ls")
  end,
})
```

### Common Language Servers

| Language | Server | Install |
|----------|--------|---------|
| Python | `pyright` | Already configured |
| Lua | `lua_ls` | Add to `ensure_installed` |
| Rust | `rust_analyzer` | Add to `ensure_installed` |
| JavaScript/TypeScript | `ts_ls` | Add to `ensure_installed` |
| C/C++ | `clangd` | Add to `ensure_installed` |
| Go | `gopls` | Add to `ensure_installed` |

Find more servers: run `:Mason` in nvim and browse the list.
## Troubleshooting

### Plugins not loading
```vim
:Lazy
```
Press `I` to install, `U` to update.

### VimTeX inverse search not working (macOS)
1. Check Skim Sync settings
2. Restart nvim and Skim
3. Recompile the document
4. Weirdly, restarting the whole machine does the trick sometimes with skim

### LSP not working
```vim
:LspInfo
:Mason
```
Ensure the language server is installed.
