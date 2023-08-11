local lsp = require("lsp-zero").preset({})

lsp.ensure_installed({
  "tsserver",
  "efm",
})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({ buffer = bufnr, preserve_mappings = true })

  vim.keymap.set({ "n", "x" }, "gq", vim.lsp.buf.format, { buffer = true })
  vim.keymap.set("n", "gR", vim.lsp.buf.rename, { buffer = true })
  vim.keymap.set("n", "ga", vim.lsp.buf.code_action, { buffer = true })
end)

-- (Optional) Configure lua language server for neovim
require("lspconfig").lua_ls.setup(lsp.nvim_lua_ls())
require("lspconfig").tailwindcss.setup({
  settings = {
    tailwindCSS = {
      classAttributes = { "class", "className", ".*Styles*" },
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
require("lspconfig").efm.setup({
  init_options = { documentFormatting = true },
  settings = {
    languages = {
      lua = {
        require("efmls-configs.linters.luacheck"),
        require("efmls-configs.formatters.stylua"),
      },
      html = {
        require("efmls-configs.formatters.prettier"),
        require("efmls-configs.linters.stylelint"),
      },
      css = {
        require("efmls-configs.formatters.prettier"),
        require("efmls-configs.linters.stylelint"),
      },
      python = {
        require("efmls-configs.formatters.autopep8"),
        require("efmls-configs.linters.flake8"),
      },
      javascript = {
        require("efmls-configs.formatters.prettier"),
        require("efmls-configs.linters.eslint_d"),
      },
      javascriptreact = {
        require("efmls-configs.formatters.prettier"),
        require("efmls-configs.linters.eslint_d"),
      },
      typescript = {
        require("efmls-configs.formatters.prettier"),
        require("efmls-configs.linters.eslint_d"),
      },
      typescriptreact = {
        require("efmls-configs.formatters.prettier"),
        require("efmls-configs.linters.eslint_d"),
      },
      graphql = {
        require("efmls-configs.formatters.prettier"),
      },
      ruby = {
        require("efmls-configs.linters.rubocop"),
      },
      markdown = {
        require("efmls-configs.formatters.prettier"),
      },
      yaml = {
        require("efmls-configs.formatters.prettier"),
      },
      json = {
        require("efmls-configs.formatters.prettier"),
      },
    },
  },
  filetypes = {
    "typescript",
    "typescriptreact",
    "javascript",
    "javascriptreact",
    "lua",
    "graphql",
    "ruby",
    "html",
    "css",
    "python",
    "markdown",
    "yaml",
    "json",
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
