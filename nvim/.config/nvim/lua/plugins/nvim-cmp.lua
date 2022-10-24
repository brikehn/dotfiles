local cmp = require('cmp')
local lspkind = require('lspkind')

cmp.setup({
  mapping = {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-u>'] = cmp.mapping.scroll_docs(4),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<C-y>'] = cmp.mapping.confirm({ select = true, }),
  },
  experimental = { ghost_text = true },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'nvim_lsp_signature_help' },
    { name = 'luasnip' },
    { name = 'fuzzy_buffer' },
    { name = 'fuzzy_path' },
  },
  formatting = {
    format = lspkind.cmp_format({
      mode = 'symbol_text',
      before = function(entry, vim_item)
        -- Source
        vim_item.menu = ({
          nvim_lsp = '[LSP]',
          luasnip = '[LuaSnip]',
          nvim_lua = '[Lua]',
          path = '[Path]'
        })[entry.source.name]
        return vim_item
      end,
    })
  },
  enabled = function()
    -- disable completion in comments
    local context = require 'cmp.config.context'
    -- keep command mode completion enabled when cursor is in a comment
    if vim.api.nvim_get_mode().mode == 'c' then
      return true
    else
      return not context.in_treesitter_capture('comment')
          and not context.in_syntax_group('Comment')
    end
  end,
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end
  }
})

cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'fuzzy_buffer' }
  }
})

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'fuzzy_path' }
  }, {
    { name = 'cmdline' }
  })
})
