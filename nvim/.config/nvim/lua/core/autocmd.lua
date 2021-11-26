vim.cmd([[
    augroup ftplugin
      au!
      au FileType vim,html,css,javascript,javascriptreact,typescript,typescriptreact,lua,sh,zsh,markdown.mdx,json setl sw=2
    augroup END
]])
