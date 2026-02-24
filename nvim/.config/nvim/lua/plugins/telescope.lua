return {
	"nvim-telescope/telescope.nvim",
	version = "*",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope-ui-select.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	},
	config = function()
		local builtin = require("telescope.builtin")
		local actions = require("telescope.actions")

		local search_dotfiles = function()
			builtin.git_files({
				prompt_title = "Dotfiles",
				cwd = vim.env.DOTFILES,
				show_untracked = true,
			})
		end

		local git_buffer_commits = function()
			builtin.git_bcommits({ git_command = { "git", "log", "--pretty=format:%h (%cr by %an) %s%n" } })
		end

		vim.keymap.set("n", "<C-p>", builtin.git_files, {})

		vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
		vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
		vim.keymap.set("n", "<leader>df", search_dotfiles, {})
		vim.keymap.set("n", "<leader>gc", git_buffer_commits, {})

		vim.keymap.set("n", "<leader>vh", builtin.help_tags, {})

		require('telescope').setup({
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
			extensions = {
				["ui-select"] = {
					require("telescope.themes").get_dropdown({
						layout_config = {
							width = 80,
						},
					}),
				},
			},
		})

		require("telescope").load_extension("fzf")
		require("telescope").load_extension("ui-select")
	end,
}
