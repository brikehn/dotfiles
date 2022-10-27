vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("nvim-tree").setup({
  view = {
    adaptive_size = true,
  },
  filters = { custom = { "^.git$" } },
})
