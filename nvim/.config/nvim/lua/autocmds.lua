vim.api.nvim_create_augroup("setIndent", { clear = true })
vim.api.nvim_create_autocmd("Filetype", {
	group = "setIndent",
	pattern = {
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"lua",
		"json",
		"jsonc",
		"graphql",
		"html",
		"sh",
	},
	command = "setlocal shiftwidth=2 tabstop=2",
})
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = { "*.thor" },
	command = "set filetype=ruby",
})
