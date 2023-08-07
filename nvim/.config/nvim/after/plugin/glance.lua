vim.keymap.set("n", "<leader>gd", "<CMD>Glance definitions<CR>")
vim.keymap.set("n", "<leader>gr", "<CMD>Glance references<CR>")
vim.keymap.set("n", "<leader>gy", "<CMD>Glance type_definitions<CR>")
vim.keymap.set("n", "<leader>gi", "<CMD>Glance implementations<CR>")

require("glance").setup({})
