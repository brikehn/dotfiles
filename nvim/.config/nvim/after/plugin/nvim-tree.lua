vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>")

vim.api.nvim_create_autocmd("QuitPre", {
	callback = function()
		local invalid_win = {}
		local wins = vim.api.nvim_list_wins()
		for _, w in ipairs(wins) do
			local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w))
			if bufname:match("NvimTree_") ~= nil then
				table.insert(invalid_win, w)
			end
		end
		if #invalid_win == #wins - 1 then
			-- Should quit, so we close all invalid windows.
			for _, w in ipairs(invalid_win) do
				vim.api.nvim_win_close(w, true)
			end
		end
	end,
})

require("nvim-tree").setup({
	sync_root_with_cwd = true,
	respect_buf_cwd = true,
	update_focused_file = {
		enable = true,
		update_root = true,
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
				default = "",
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
