local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

require("lsp-setup").setup({
  installer = { automatic_installation = true },
  default_mappings = true,
  mappings = {
    ['<space>f'] = 'lua vim.lsp.buf.format({ async = true })',
  },
  -- on_attach = function(client, bufnr)
  --   require("lsp-setup.utils").format_on_save(client)
  -- end,
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
  servers = {
    tsserver = {},
    sumneko_lua = {
      settings = {
        Lua = {
          runtime = {
            version = "LuaJIT",
            path = runtime_path,
          },
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true),
          },
        },
      },
    },
  },
})
