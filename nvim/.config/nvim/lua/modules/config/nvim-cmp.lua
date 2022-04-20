return function()
  local cmp = safe_require("cmp")
  local luasnip = safe_require("luasnip")
  if not cmp or not luasnip then
    return
  end

  cmp.setup({
    snippet = {
      expand = function(args)
        require("luasnip").lsp_expand(args.body)
      end,
    },
    mapping = {
      ["<C-p>"] = cmp.mapping.select_prev_item(),
      ["<C-n>"] = cmp.mapping.select_next_item(),
      ["<C-d>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-e>"] = cmp.mapping.close(),
      ["<C-y>"] = cmp.mapping.confirm({
        behavior = cmp.ConfirmBehavior.Replace,
        select = true,
      }),
    },
    experimental = { ghost_text = true },
    sources = {
      { name = "nvim_lua" },
      { name = "nvim_lsp" },
      { name = "treesitter" },
      { name = "luasnip" },
      { name = "path" },
      { name = "spell", keyword_length = 5 },
      { name = "buffer", keyword_length = 5 },
      { name = "calc" },
    },
    formatting = {
      format = function(entry, vim_item)
        -- Source
        vim_item.menu = ({
          buffer = "[Buffer]",
          nvim_lsp = "[LSP]",
          luasnip = "[LuaSnip]",
          nvim_lua = "[Lua]",
          latex_symbols = "[LaTeX]",
        })[entry.source.name]
        return vim_item
      end,
    },
  })

  cmp.setup.cmdline("/", {
    sources = {
      { name = "buffer" },
    },
  })
end
