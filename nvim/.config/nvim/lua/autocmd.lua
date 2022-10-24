vim.cmd([[
    augroup ftplugin
      au!
      au FileType vim,html,css,scss,sass,javascript,javascriptreact,typescript,typescriptreact,lua,sh,zsh,markdown.mdx,json,graphql,prisma setl sw=2
    augroup END
]])
