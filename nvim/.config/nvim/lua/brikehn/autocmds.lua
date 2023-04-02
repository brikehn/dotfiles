vim.api.nvim_create_augroup('setIndent', { clear = true })
vim.api.nvim_create_autocmd('Filetype', {
  group = 'setIndent',
  pattern = { 'javascript', 'typescript', 'lua' },
  command = 'setlocal shiftwidth=2 tabstop=2'
})
