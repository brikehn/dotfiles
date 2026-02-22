vim.filetype.add({
  pattern = {
    [".*/.config/git/.*"] = "gitconfig",
    [".*/.config/git/ignore.*"] = "gitignore",
  },
})
