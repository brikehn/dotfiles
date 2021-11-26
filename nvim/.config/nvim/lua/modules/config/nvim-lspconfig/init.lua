return function()
  local lspconfig = safe_require("lspconfig")
  if not lspconfig then
    return
  end

  local on_attach = require("modules.config.nvim-lspconfig.on-attach")
  local format_config = require("modules.config.nvim-lspconfig.format")

  local runtime_path = vim.split(package.path, ";")
  table.insert(runtime_path, "lua/?.lua")
  table.insert(runtime_path, "lua/?/init.lua")

  local servers = {
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
    efm = {
      filetypes = vim.tbl_keys(format_config),
      init_options = { documentFormatting = true },
      root_dir = lspconfig.util.root_pattern({ ".git/", "." }),
      settings = { languages = format_config },
    },
  }

  local function get_config(server_name)
    local config = servers[server_name] or {}
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    if package.loaded["cmp_nvim_lsp"] then
      capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)
    end
    config.on_attach = on_attach
    return config
  end

  require("nvim-lsp-installer").on_server_ready(function(server)
    server:setup(get_config(server.name))
  end)
end
