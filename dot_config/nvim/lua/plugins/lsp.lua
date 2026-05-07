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
		opts = {},
		config = function(_, opts)
			-- templ is mise-managed, not Mason — enable manually
			vim.lsp.enable("templ")

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
			vim.lsp.config("tailwindcss", {
				settings = {
					tailwindCSS = {
						classFunctions = {
							"Merge",
							"Merge",
							"tailwind\\.Merge",
						},
						experimental = {
							classRegex = {
								"Merge\\(([^)]*)\\)",
								"tailwind\\.Merge\\(([^)]*)\\)",
							},
						},
					},
				},
			})

			require("mason-lspconfig").setup(opts)
		end,
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"neovim/nvim-lspconfig",
			{
				"WhoIsSethDaniel/mason-tool-installer.nvim",
				opts = {
					integrations = { ["mason-lspconfig"] = true },
					ensure_installed = {
						-- LSP
						"lua_ls",
						"tailwindcss",
						"gopls",
						"ts_ls",
						"cssls",
						"html",
						"jsonls",
						"bashls",
						"yamlls",
						"graphql",
						"sqlls",
						"ruby_lsp",
						"dockerls",
						-- formatters
						"prettier",
						"stylua",
						"shfmt",
						"taplo",
						"rubocop",
						-- linters
						"stylelint",
						"hadolint",
						"golangci-lint",
						"eslint_d",
						"jsonlint",
						"luacheck",
						"checkmake",
						"shellcheck",
						"actionlint",
					},
				},
			},
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
