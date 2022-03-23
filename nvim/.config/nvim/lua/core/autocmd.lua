vim.cmd([[
    augroup ftplugin
      au!
      au FileType vim,html,css,scss,sass,javascript,javascriptreact,typescript,typescriptreact,lua,sh,zsh,markdown.mdx,json,graphql,prisma setl sw=2
    augroup END
]])

vim.cmd([[
  command! -nargs=? -complete=command Scratch lua scratch(<q-args>)
  command! -nargs=? -complete=command S lua scratch(<q-args>)
]])

function scratch(filetype)
  filetype = (filetype == "" and "Scratch") or filetype
  vim.api.nvim_command("tabnew")

  vim.api.nvim_buf_set_name(0, "[" .. filetype .. "]")
  vim.api.nvim_buf_set_option(0, "buftype", "nofile")
  vim.api.nvim_buf_set_option(0, "swapfile", false)
  vim.api.nvim_buf_set_option(0, "filetype", filetype)
  vim.api.nvim_buf_set_option(0, "bufhidden", "wipe")
end
