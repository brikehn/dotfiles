return {
	{
		"mason-org/mason-lspconfig.nvim",
		lazy = false,
		keys = {
			{ "gd", vim.lsp.buf.definition, desc = "Goto Definition" },
			{ "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
			{ "gR", vim.lsp.buf.rename, desc = "Rename" },
			{ "gr", "<CMD>Glance references<CR>", desc = "References", nowait = true },
			{ "gi", "<CMD>Glance implementations<CR>", desc = "implementations" },
			{ "gy", "<CMD>Glance type_definitions<CR>", desc = "T[y]pe Definitions" },
			{
				"ga",
				vim.lsp.buf.code_action,
				mode = { "n", "x" },
				desc = "Code Action",
			},
			{ "gl", vim.diagnostic.open_float, desc = "Open float" },
			{
				"gK",
				function()
					return vim.lsp.buf.signature_help()
				end,
				desc = "Signature Help",
			},
			{
				"<c-k>",
				function()
					return vim.lsp.buf.signature_help()
				end,
				mode = "i",
				desc = "Signature Help",
			},
		},
		opts = function()
			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						runtime = {
							version = "LuaJIT",
							pathScript = false,
						},
						workspace = {
							ignoreDir = {},
						},
						telemetry = {
							enable = false,
						},
					},
				},
			})
		end,
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"neovim/nvim-lspconfig",
		},
	},
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

			return {
				formatters_by_ft = {
					css = { "prettier" },
					go = { "gofmt" },
					graphql = { "prettier" },
					html = { "prettier" },
					javascript = { "prettier" },
					javascriptreact = { "prettier" },
					json = { "prettier" },
					lua = { "stylua" },
					markdown = { "prettier" },
					ruby = { "rubocop" },
					typescript = { "prettier" },
					typescriptreact = { "prettier" },
					yaml = { "prettier" },
				},
			}
		end,
	},
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local lint = require("lint")
			lint.linters_by_ft = {
				css = { "stylelint" },
				docker = { "hadolint" },
				go = { "golangcilint" },
				html = { "stylelint" },
				javascript = { "eslint_d" },
				javascriptreact = { "eslint_d" },
				json = { "jsonlint" },
				lua = { "luacheck" },
				make = { "checkmake" },
				markdown = { "markdownlint" },
				ruby = { "rubocop" },
				typescript = { "eslint_d" },
				typescriptreact = { "eslint_d" },
				yaml = { "yamllint" },
			}

			local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
			vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
				group = lint_augroup,
				callback = function()
					lint.try_lint()
				end,
			})

			local luacheck = lint.linters.luacheck
			-- Add vim globals support to nvim-lint luacheck args
			luacheck.args = { "--formatter", "plain", "--codes", "--ranges", "--globals", "vim", "reload", "--" }
		end,
	},
	{
		"dnlhc/glance.nvim",
		cmd = "Glance",
	},
	{
		"folke/lazydev.nvim",
		ft = "lua", -- only load on lua files
		cmd = "LazyDev",
		opts = {
			library = {
				{ path = "lazy.nvim", words = { "LazyVim" } },
			},
		},
	},
}
