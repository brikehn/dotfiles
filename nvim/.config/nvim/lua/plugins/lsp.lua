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
			{
				"gq",
				function()
					return vim.lsp.buf.format({ timeout_ms = 10000 })
				end,
				mode = { "n", "x" },
				desc = "Format Document",
			},
		},
		opts = function(_, opts)
			-- Linters
			local checkmake = require("efmls-configs.linters.checkmake")
			local eslint = require("efmls-configs.linters.eslint_d")
			local flake8 = require("efmls-configs.linters.flake8")
			local golangci_lint = require("efmls-configs.linters.golangci_lint")
			local hadolint = require("efmls-configs.linters.hadolint")
			local jsonlint = require("efmls-configs.linters.jsonlint")
			local luacheck = require("efmls-configs.linters.luacheck")
			local markdownlint = require("efmls-configs.linters.markdownlint")
			local rubocopLint = require("efmls-configs.linters.rubocop")
			local stylelint = require("efmls-configs.linters.stylelint")
			local yamllint = require("efmls-configs.linters.yamllint")

			-- Formatters
			local autopep8 = require("efmls-configs.formatters.autopep8")
			local gofmt = require("efmls-configs.formatters.gofmt")
			local prettier = require("efmls-configs.formatters.prettier")
			local rubocopFormat =
				{ formatCommand = "bundle exec rubocop -A -f quiet --stderr -s ${INPUT}", formatStdin = true }
			local stylua = require("efmls-configs.formatters.stylua")

			local languages = require("efmls-configs.defaults").languages()
			languages = vim.tbl_extend("force", languages, {
				-- Custom languages, or override existing ones
				css = { stylelint, prettier },
				docker = { hadolint },
				go = { golangci_lint, gofmt },
				graphql = { prettier },
				html = { stylelint, prettier },
				javascript = { eslint, prettier },
				javascriptreact = { eslint, prettier },
				json = { jsonlint, prettier },
				jsonc = { jsonlint, prettier },
				lua = { luacheck, stylua },
				make = { checkmake },
				markdown = { markdownlint, prettier },
				python = { flake8, autopep8 },
				ruby = { rubocopLint, rubocopFormat },
				typescript = { eslint, prettier },
				typescriptreact = { eslint, prettier },
				yaml = { yamllint, prettier },
			})

			local efmls_config = {
				filetypes = vim.tbl_keys(languages),
				settings = {
					rootMarkers = { ".git/" },
					languages = languages,
				},
				init_options = {
					documentFormatting = true,
					documentRangeFormatting = true,
				},
			}

			vim.lsp.config(
				"efm",
				vim.tbl_extend("force", efmls_config, {
					cmd = { "efm-langserver" },
					-- capabilities = capabilities,
				})
			)

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

			opts.ensure_installed = { "efm" }
		end,
		dependencies = {
			{ "creativenull/efmls-configs-nvim", version = "v1.10.1" },
			{ "mason-org/mason.nvim", opts = {} },
			"neovim/nvim-lspconfig",
		},
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
