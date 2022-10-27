local map = require("utils").map
vim.g.mapleader = " "

-- map C-c to Esc
map("i", "<C-c>", "<Esc>")
map("n", "<C-c>", "<Esc>")

map("v", "<leader>f", "<cmd>lua vim.lsp.buf.format()<CR>") -- Range formatting

-- TELESCOPE --
-- File Pickers
map("n", "<C-p>", "<cmd>Telescope git_files<CR>")
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>")
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>")
map("n", "<leader>df", '<cmd>lua require("plugins.telescope").search_dotfiles()<CR>')
-- Vim Pickers
map("n", "<leader>vb", '<cmd>lua require("telescope.builtin").buffers({ sort_mru = true })<CR>')
map("n", "<leader>vh", "<cmd>Telescope help_tags<CR>")
map("n", "<leader>vr", "<cmd>Telescope registers<CR>")
-- LSP Pickers
map("n", "<leader>ls", "<cmd>Telescope lsp_document_symbols<CR>")
map("n", "<leader>gd", "<cmd>Telescope lsp_definitions<CR>")
map("n", "<leader>gt", "<cmd>Telescope lsp_type_definitions<CR>")
map("n", "<leader>gi", "<cmd>Telescope lsp_implementations<CR>")
-- Git
map("n", "<leader>gc", "<cmd>Telescope git_commits<CR>")
map("n", "<leader>gb", "<cmd>Telescope git_bcommits<CR>")
map("n", "<leader>gs", "<cmd>Telescope git_status<CR>")

-- NvimTree
map("n", "<C-n>", "<cmd>NvimTreeToggle<CR>")
