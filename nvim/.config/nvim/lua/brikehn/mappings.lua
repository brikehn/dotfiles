vim.g.mapleader = " "
-- vim.keymap.set("n", "<C-n>", vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.g.tmux_navigator_no_mappings = 1
vim.keymap.set("n", "<C-w>h", "<cmd>TmuxNavigateLeft<CR>", { silent = true, noremap = true })
vim.keymap.set("n", "<C-w>j", "<cmd>TmuxNavigateDown<CR>", { silent = true, noremap = true })
vim.keymap.set("n", "<C-w>k", "<cmd>TmuxNavigateUp<CR>", { silent = true, noremap = true })
vim.keymap.set("n", "<C-w>l", "<cmd>TmuxNavigateRight<CR>", { silent = true, noremap = true })

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("x", "<leader>p", [["_dP]])

vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
