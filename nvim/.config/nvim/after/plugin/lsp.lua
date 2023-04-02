local lsp = require("lsp-zero").preset({})

lsp.ensure_installed({
  "tsserver",
})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({ buffer = bufnr })
end)

-- (Optional) Configure lua language server for neovim
require("lspconfig").lua_ls.setup(lsp.nvim_lua_ls())

lsp.setup()

local cmp = require("cmp")
local cmp_action = require("lsp-zero").cmp_action()

require("luasnip.loaders.from_vscode").lazy_load()

require("luasnip").filetype_extend("ruby", { "rails" })

cmp.setup({
  mapping = {
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-f>"] = cmp_action.luasnip_jump_forward(),
    ["<C-b>"] = cmp_action.luasnip_jump_backward(),
  },
  sources = {
    { name = "path" },
    { name = "nvim_lsp_signature_help" },
    { name = "nvim_lsp" },
    { name = "nvim_lua" },
    { name = "buffer",                 keyword_length = 3 },
    { name = "luasnip",                keyword_length = 2 },
  },
  experimental = { ghost_text = true },
  formatting = {
    format = function(entry, item)
      item.menu = ({
        buffer = "[Buffer]",
        nvim_lsp = "[LSP]",
        nvim_lsp_signature_help = "[LSP]",
        luasnip = "[LuaSnip]",
        nvim_lua = "[Lua]",
        path = "[Path]",
      })[entry.source.name]
      return item
    end,
  },
})

require("mason-null-ls").setup({
	ensure_installed = { "stylua", "eslint_d", "prettier" },
	automatic_installation = false,
	automatic_setup = true, -- Recommended, but optional})
})

require("mason-null-ls").setup_handlers()

require("null-ls").setup()
