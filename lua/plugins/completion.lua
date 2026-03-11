-- Auto-completion: plugins and configs
return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-omni",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    -- Load your custom snippets
    require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/luasnippets" })

    -- Snippet jump keymaps
    vim.keymap.set({ "i", "s" }, "<C-j>", function()
      luasnip.jump(1)
    end, { silent = true })
    vim.keymap.set({ "i", "s" }, "<C-k>", function()
      luasnip.jump(-1)
    end, { silent = true })

    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping.select_next_item(),
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "omni" },
        { name = "buffer" },
        { name = "path" },
      }),
    })
  end,
}
