vim.api.nvim_create_augroup("setIndent", { clear = true })
vim.api.nvim_create_autocmd("Filetype", {
	group = "setIndent",
	pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact", "lua", "json", "jsonc" },
	command = "setlocal shiftwidth=2 tabstop=2",
})
