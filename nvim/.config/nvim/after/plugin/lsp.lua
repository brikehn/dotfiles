local lsp = require("lsp-zero").preset({})

lsp.ensure_installed({
  "tsserver",
})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({ buffer = bufnr, preserve_mappings = false })

  vim.keymap.set({ "n", "x" }, "gq", vim.lsp.buf.format, { buffer = true })
  vim.keymap.set("n", "gR", vim.lsp.buf.rename, { buffer = true })
  vim.keymap.set("n", "ga", vim.lsp.buf.code_action, { buffer = true })
end)

-- (Optional) Configure lua language server for neovim
require("lspconfig").lua_ls.setup(lsp.nvim_lua_ls())
require("lspconfig").tailwindcss.setup({
  settings = {
    tailwindCSS = {
      classAttributes = { ".*Styles*" },
      experimental = {
        classRegex = {
          {
            "clsx\\(([^)]*)\\)",
            "(?:'|\"|`)([^']*)(?:'|\"|`)",
          },
        },
      },
    },
  },
})

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

local null_ls = require("null-ls")
require("mason-null-ls").setup({
  ensure_installed = { "stylua", "eslint_d", "prettier" },
  automatic_setup = true,
  handlers = {},
})

null_ls.setup()
