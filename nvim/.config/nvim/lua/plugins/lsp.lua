return {
	{ "folke/neodev.nvim", opts = {} },
	{ "creativenull/efmls-configs-nvim", version = "v1.2.0" },
	{ "williamboman/mason.nvim", opts = {} },
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			{ "neovim/nvim-lspconfig" },
		},
		opts = {},
		config = function()
			vim.lsp.set_log_level("debug")
			vim.keymap.set("n", "gl", vim.diagnostic.open_float)
			vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
			vim.keymap.set("n", "]d", vim.diagnostic.goto_next)

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(event)
					local opts = { buffer = event.buf }

					vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
					vim.keymap.set("n", "go", vim.lsp.buf.type_definition, opts)
					vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
					vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)

					vim.keymap.set({ "n", "x", "v" }, "gq", function()
						vim.lsp.buf.format({ name = "efm", async = true })
					end, opts)
					vim.keymap.set("n", "gR", vim.lsp.buf.rename, opts)
					vim.keymap.set({ "n", "v" }, "ga", vim.lsp.buf.code_action, opts)
				end,
			})

			local capabilities = vim.tbl_deep_extend(
				"force",
				vim.lsp.protocol.make_client_capabilities(),
				require("cmp_nvim_lsp").default_capabilities()
			)

			require("mason-lspconfig").setup_handlers({
				function(server_name) -- default handler
					require("lspconfig")[server_name].setup({
						capabilities = capabilities,
					})
				end,
				efm = function()
					local eslint = require("efmls-configs.linters.eslint")
					local prettier = require("efmls-configs.formatters.prettier")
					local luacheck = require("efmls-configs.linters.luacheck")
					local stylua = require("efmls-configs.formatters.stylua")
					local gofmt = require("efmls-configs.formatters.gofmt")
					local golangci_lint = require("efmls-configs.linters.golangci_lint")
					local stylelint = require("efmls-configs.linters.stylelint")
					local autopep8 = require("efmls-configs.formatters.autopep8")
					local flake8 = require("efmls-configs.linters.flake8")
					local rubocop = require("efmls-configs.linters.rubocop")

					local languages = {
						html = { stylelint, prettier },
						css = { stylelint, prettier },
						python = { flake8, autopep8 },
						javascript = { eslint, prettier },
						javascriptreact = { eslint, prettier },
						typescript = { eslint, prettier },
						typescriptreact = { eslint, prettier },
						graphql = { prettier },
						markdown = { prettier },
						yaml = { prettier },
						json = { prettier },
						ruby = { rubocop },
						lua = { luacheck, stylua },
						go = { golangci_lint, gofmt },
					}

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

					require("lspconfig").efm.setup(efmls_config)
				end,
			})
		end,
	},
	{
		"dnlhc/glance.nvim",
		opts = {},
		config = function()
			vim.keymap.set("n", "<leader>gd", "<CMD>Glance definitions<CR>")
			vim.keymap.set("n", "<leader>gr", "<CMD>Glance references<CR>")
			vim.keymap.set("n", "<leader>go", "<CMD>Glance type_definitions<CR>")
			vim.keymap.set("n", "<leader>gi", "<CMD>Glance implementations<CR>")
		end,
	},
}
