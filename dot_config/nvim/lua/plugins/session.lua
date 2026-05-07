return {
	"dhruvasagar/vim-prosession",
	dependencies = {
		"tpope/vim-obsession",
	},
	init = function()
		vim.g.prosession_per_branch = 1
		vim.g.prosession_on_startup = 0
	end,
}
