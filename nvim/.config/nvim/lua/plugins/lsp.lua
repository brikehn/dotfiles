local prettier = { formatCommand = 'prettier --stdin-filepath ${INPUT}', formatStdin = true }

local eslint = {
  lintCommand = 'eslint_d -f unix --stdin --stdin-filename ${INPUT}',
  lintStdin = true,
  lintFormats = { '%f:%l:%c: %m' },
  lintIgnoreExitCode = true,
}

local stylua = { formatCommand = 'stylua -s --indent-type="Spaces" --indent-width=2 -', formatStdin = true }

local shfmt = { formatCommand = 'shfmt -i 2 -ci -s -bn', formatStdin = true }

local black = { formatCommand = 'black --quiet -', formatStdin = true }

local flake8 = {
  lintCommand = 'flake8 --stdin-display-name ${INPUT} -',
  lintStdin = true,
  lintFormats = { '%f:%l:%c: %m' },
}

local rustfmt = { formatCommand = 'rustfmt', formatStdin = true }

local rubocop = { formatCommand = 'bundle exec rubocop -A -f quiet --stderr -s ${INPUT}', formatStdin = true }

local languages = {
  lua = { stylua },
  sh = { shfmt },
  typescript = { prettier, eslint },
  javascript = { prettier, eslint },
  typescriptreact = { prettier, eslint },
  javascriptreact = { prettier, eslint },
  html = { prettier },
  css = { prettier },
  json = { prettier },
  ['markdown.mdx'] = { prettier },
  markdown = { prettier },
  graphql = { prettier },
  python = { black, flake8 },
  yaml = { prettier },
  rust = { rustfmt },
  prisma = { prettier },
  ruby = { rubocop }
}

local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')

require('lsp-format').setup()
vim.cmd [[cabbrev wq execute "Format sync" <bar> wq]] -- format on :wq

require('nvim-lsp-setup').setup({
  installer = {
    automatic_installation = true
  },
  default_mappings = false,
  mappings = {
    gD = 'lua vim.lsp.buf.declaration()',
    gd = 'lua vim.lsp.buf.definition()',
    gt = 'lua vim.lsp.buf.type_definition()',
    gi = 'lua vim.lsp.buf.implementation()',
    gr = 'lua vim.lsp.buf.references()',
    K = 'lua vim.lsp.buf.hover()',
    ['<C-s>'] = 'lua vim.lsp.buf.signature_help()',
    ['<space>rn'] = 'lua vim.lsp.buf.rename()',
    ['<space>ca'] = 'lua vim.lsp.buf.code_action()',
    ['<space>f'] = 'lua vim.lsp.buf.formatting()',
    ['<space>e'] = 'lua vim.diagnostic.open_float()',
    ['[d'] = 'lua vim.diagnostic.goto_prev()',
    [']d'] = 'lua vim.diagnostic.goto_next()',
  },
  on_attach = function(client, bufnr)
    require('lsp-format').on_attach(client)
    if client.name == 'efm' then
      require('nvim-lsp-setup.utils').format_on_save(client)
    else
      require('nvim-lsp-setup.utils').disable_formatting(client)
    end
  end,
  capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities()),
  servers = {
    efm = {
      init_options = { documentFormatting = true },
      settings = { languages = languages },
      filetypes = vim.tbl_keys(languages)
    },
    solargraph = {},
    tsserver = {},
    sumneko_lua = {
      settings = {
        Lua = {
          runtime = {
            version = 'LuaJIT',
            path = runtime_path,
          },
          diagnostics = {
            globals = { 'vim' },
          },
          workspace = {
            library = vim.api.nvim_get_runtime_file('', true),
          },
        },
      },
    }
  }
})
