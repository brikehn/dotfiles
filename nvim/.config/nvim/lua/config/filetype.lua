vim.filetype.add({
	extension = {
		templ = "templ",
		thor = "ruby",
	},
	pattern = {
		[".*/.config/git/.*"] = "gitconfig",
		[".*/.config/git/ignore.*"] = "gitignore",
	},
})
