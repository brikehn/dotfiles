return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.6",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local builtin = require("telescope.builtin")
		local actions = require("telescope.actions")

		local search_dotfiles = function()
			builtin.find_files({
				prompt_title = "Dotfiles",
				cwd = vim.env.DOTFILES,
				hidden = true,
			})
		end

		require("telescope").setup({
			defaults = {
				mappings = {
					i = {
						["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
					},
					n = {
						["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
					},
				},
			},
		})

		vim.keymap.set("n", "<C-p>", builtin.git_files, {})

		vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
		vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
		vim.keymap.set("n", "<leader>df", search_dotfiles, {})

		vim.keymap.set("n", "<leader>vh", builtin.help_tags, {})
	end,
}
