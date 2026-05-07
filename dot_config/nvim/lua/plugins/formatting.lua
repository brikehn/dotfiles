return {
	{
		"stevearc/conform.nvim",
		events = { "BufReadPre", "BufNewFile" },
		keys = {
			{
				"gq",
				function()
					require("conform").format({ async = false }, function(err)
						if not err then
							local mode = vim.api.nvim_get_mode().mode
							if vim.startswith(string.lower(mode), "v") then
								vim.api.nvim_feedkeys(
									vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
									"n",
									true
								)
							end
						end
					end)
				end,
				mode = { "n", "v" },
				desc = "Format code",
			},
		},
		opts = function()
			vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

			-- mason: prettier stylua shfmt taplo rubocop
			-- mise: gofmt(go) templ rustywind
			return {
				formatters_by_ft = {
					css = { "prettier" },
					go = { "gofmt" }, -- mise-managed
					graphql = { "prettier" },
					html = { "prettier" },
					javascript = { "prettier" },
					javascriptreact = { "prettier" },
					json = { "prettier" },
					lua = { "stylua" },
					markdown = { "prettier" },
					ruby = { "rubocop" },
					sh = { "shfmt" },
					templ = { "templ", "rustywind" }, -- mise-managed
					toml = { "taplo" },
					typescript = { "prettier" },
					typescriptreact = { "prettier" },
					yaml = { "prettier" },
				},
			}
		end,
	},
}
