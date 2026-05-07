-- must be set before sql ftplugin loads
vim.g.omni_sql_no_default_maps = 1

vim.filetype.add({
	extension = {
		templ = "templ",
		thor = "ruby",
	},
	pattern = {
		-- chezmoi source paths
		[".*dot_zprofile"] = "zsh",
		[".*dot_zshrc"] = "zsh",
		[".*dot_zshenv"] = "zsh",
		[".*dot_config/git/config"] = "gitconfig",
		[".*dot_config/git/ssh"] = "gitconfig",
		[".*dot_config/git/ignore"] = "gitignore",
		-- live paths
		[".*/%.config/git/config"] = "gitconfig",
		[".*/%.config/git/dailypay"] = "gitconfig",
		[".*/%.config/git/ignore"] = "gitignore",
		[".*/%.config/zsh/work"] = "zsh",
		[".*/%.config/zsh/secrets"] = "zsh",
	},
})

local autocmd = vim.api.nvim_create_autocmd

autocmd("FileType", {
	pattern = { "go", "templ" },
	callback = function()
		vim.opt_local.tabstop = 4
		vim.opt_local.shiftwidth = 4
	end,
})

autocmd("FileType", {
	pattern = "sh",
	callback = function()
		vim.opt_local.tabstop = 4
		vim.opt_local.shiftwidth = 4
		vim.opt_local.expandtab = false
	end,
})

autocmd("FileType", {
	pattern = "lua",
	callback = function()
		vim.opt_local.tabstop = 3
		vim.opt_local.shiftwidth = 3
	end,
})

autocmd("FileType", {
	pattern = "toml",
	callback = function()
		vim.opt_local.tabstop = 2
		vim.opt_local.shiftwidth = 2
	end,
})
