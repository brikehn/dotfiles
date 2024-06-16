return {
	{ "creativenull/efmls-configs-nvim", version = "v1.2.0" },
	{ "williamboman/mason.nvim", opts = {} },
	{ "neovim/nvim-lspconfig" },
	{
		"williamboman/mason-lspconfig.nvim",
		opts = {},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(event)
					local opts = { buffer = event.buf }

					vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

					vim.keymap.set({ "n", "x", "v" }, "gq", function()
						vim.lsp.buf.format({
							filter = function(client)
								return client.name == "efm" or client.name == "templ"
							end,
							async = true,
						})
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
					local eslint = require("efmls-configs.linters.eslint_d")
					local prettier = require("efmls-configs.formatters.prettier")
					local luacheck = require("efmls-configs.linters.luacheck")
					local stylua = require("efmls-configs.formatters.stylua")
					local gofmt = require("efmls-configs.formatters.gofmt")
					local stylelint = require("efmls-configs.linters.stylelint")
					local autopep8 = require("efmls-configs.formatters.autopep8")
					local flake8 = require("efmls-configs.linters.flake8")
					local rubocopLint = require("efmls-configs.linters.rubocop")
					local rubocopFormat = {
						formatCommand = "bundle exec rubocop -A -f quiet --stderr -s ${INPUT}",
						formatStdin = true,
					}

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
						ruby = { rubocopLint, rubocopFormat },
						lua = { luacheck, stylua },
						go = { gofmt },
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

					require("lspconfig").efm.setup(vim.tbl_extend("force", efmls_config, {
						capabilities = capabilities,
					}))
				end,
			})
		end,
	},
	{
		"dnlhc/glance.nvim",
		opts = {},
		config = function()
			vim.keymap.set("n", "gr", "<CMD>Glance references<CR>")
			vim.keymap.set("n", "go", "<CMD>Glance type_definitions<CR>")
			vim.keymap.set("n", "gi", "<CMD>Glance implementations<CR>")
		end,
	},
}
