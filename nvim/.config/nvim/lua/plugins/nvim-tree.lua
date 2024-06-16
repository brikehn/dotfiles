return {
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		lazy = false,
		init = function()
			vim.g.loaded_netrw = 1
			vim.g.loaded_netrwPlugin = 1
		end,
		config = function()
			require("nvim-tree").setup({
				sync_root_with_cwd = true,
				respect_buf_cwd = true,
				update_focused_file = {
					enable = true,
					update_root = true,
				},
				filesystem_watchers = {
					enable = true,
					debounce_delay = 50,
					ignore_dirs = {
						"node_modules",
					},
				},
				modified = {
					enable = true,
				},
				view = {
					side = "right",
					width = {
						min = 30,
						max = 50,
					},
				},
				renderer = {
					root_folder_label = ":t",
					icons = {
						show = {
							folder_arrow = false,
						},
						git_placement = "after",
						glyphs = {
							default = "",
							symlink = "",
							git = {
								unstaged = "",
								staged = "S",
								unmerged = "",
								renamed = "➜",
								untracked = "U",
								deleted = "✘",
								ignored = "?",
							},
						},
					},
					indent_markers = {
						enable = true,
					},
					highlight_git = true,
				},
				diagnostics = {
					enable = true,
					show_on_dirs = true,
				},
				filters = {
					git_ignored = false,
					custom = { "^.git$" },
				},
			})
			vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>")
		end,
	},
}
