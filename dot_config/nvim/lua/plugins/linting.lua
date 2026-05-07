return {
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local lint = require("lint")

			-- mason: stylelint hadolint golangci-lint eslint_d jsonlint luacheck checkmake shellcheck actionlint rubocop
			-- note: nvim-lint names differ from mason names in some cases (golangcilint vs golangci-lint)
			lint.linters_by_ft = {
				bash = { "shellcheck" },
				css = { "stylelint" },
				docker = { "hadolint" },
				go = { "golangcilint" }, -- mason: golangci-lint
				html = { "stylelint" },
				javascript = { "eslint_d" },
				javascriptreact = { "eslint_d" },
				json = { "jsonlint" },
				lua = { "luacheck" },
				make = { "checkmake" },
				ruby = { "rubocop" },
				sh = { "shellcheck" },
				zsh = { "shellcheck" },
				typescript = { "eslint_d" },
				typescriptreact = { "eslint_d" },
				yaml = { "actionlint" },
			}

			local luacheck = lint.linters.luacheck
			luacheck.args = { "--formatter", "plain", "--codes", "--ranges", "--globals", "vim", "reload", "--" }

			local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
			vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
				group = lint_augroup,
				callback = function()
					lint.try_lint()
				end,
			})
		end,
	},
}
