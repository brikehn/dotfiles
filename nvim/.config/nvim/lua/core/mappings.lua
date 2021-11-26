local map = require("core.utils").keymap.map
vim.g.mapleader = " "

-- map C-c to Esc
map("i", "<C-c>", "<Esc>")
map("n", "<C-c>", "<Esc>")

-- pane navigation w/o <C-w>
map("n", "<C-k>", ":wincmd k<CR>")
map("n", "<C-j>", ":wincmd j<CR>")
map("n", "<C-h>", ":wincmd h<CR>")
map("n", "<C-l>", ":wincmd l<CR>")

-- TELESCOPE --
-- file pickers
map("n", "<leader>ff", "<cmd>lua require('core.utils').project_files()<CR>")
map("n", "<leader>fw", "<cmd>Telescope grep_string<CR>")
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>")
map("n", "<leader>fb", "<cmd>Telescope current_buffer_fuzzy_find<CR>")
-- vim pickers
map("n", "<leader>vb", "<cmd>lua require('telescope.builtin').buffers({ sort_mru = true })<CR>")
map("n", "<leader>vh", "<cmd>Telescope help_tags<CR>")
map("n", "<leader>vr", "<cmd>Telescope registers<CR>")
-- lsp pickers
map("n", "<leader>ls", "<cmd>Telescope lsp_document_symbols<CR>")
map("n", "<leader>le", "<cmd>Telescope lsp_document_diagnostics<CR>")
map("n", "<leader>ld", "<cmd>Telescope lsp_workspace_diagnostics<CR>")
-- git
map("n", "<leader>gc", "<cmd>Telescope git_commits<CR>")
map("n", "<leader>gb", "<cmd>Telescope git_bcommits<CR>")
map("n", "<leader>gs", "<cmd>Telescope git_status<CR>")
map("n", "<leader>gn", "<cmd>lua require('telescope').extensions.git_worktree.create_git_worktree()<CR>")
map("n", "<leader>gw", "<cmd>lua require('telescope').extensions.git_worktree.git_worktrees()<CR>")
-- treesitter
map("n", "<leader>tt", "<cmd>Telescope treesitter<CR>")

-- NVIM-TREE --
map("n", "<C-n>", ":NvimTreeToggle<CR>")
map("n", "<leader>r", ":NvimTreeRefresh<CR>")
