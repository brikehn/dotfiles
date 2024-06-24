return {
	{
		"stevearc/oil.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local detail = false

			local git_ignored = setmetatable({}, {
				__index = function(self, key)
					local proc = vim.system(
						{ "git", "ls-files", "--ignored", "--exclude-standard", "--others", "--directory" },
						{
							cwd = key,
							text = true,
						}
					)
					local result = proc:wait()
					local ret = {}
					if result.code == 0 then
						for line in vim.gsplit(result.stdout, "\n", { plain = true, trimempty = true }) do
							-- Remove trailing slash
							line = line:gsub("/$", "")
							table.insert(ret, line)
						end
					end

					rawset(self, key, ret)
					return ret
				end,
			})

			require("oil").setup({
				columns = { "icon" },
				keymaps = {
					["<C-c>"] = false,
					["<Esc>"] = "actions.close",
					["<C-l>"] = {
						"actions.select",
						opts = { vertical = true },
						desc = "Open the entry in a vertical split",
					},
					["<C-j>"] = {
						"actions.select",
						opts = { horizontal = true },
						desc = "Open the entry in a horizontal split",
					},
					["<C-p>"] = false,
					["gp"] = "actions.preview",
					["<C-y>"] = "actions.yank_entry",
					["<C-u>"] = "actions.preview_scroll_up",
					["<C-d>"] = "actions.preview_scroll_down",
					["gd"] = {
						desc = "Toggle file detail view",
						callback = function()
							detail = not detail
							if detail then
								require("oil").set_columns({ "icon", "permissions", "size", "mtime" })
							else
								require("oil").set_columns({ "icon" })
							end
						end,
					},
				},
				view_options = {
					show_hidden = true,
					is_hidden_file = function(name, _)
						-- dotfiles are always considered hidden
						if vim.startswith(name, ".") then
							return true
						end
						local dir = require("oil").get_current_dir()
						-- if no local directory (e.g. for ssh connections), always show
						if not dir then
							return false
						end
						-- Check if file is gitignored
						return vim.list_contains(git_ignored[dir], name)
					end,
				},
			})

			-- Open parent directory in current window
			vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
		end,
	},
}
