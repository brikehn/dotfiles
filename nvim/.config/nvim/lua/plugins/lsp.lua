return {
	{
		"mason-org/mason-lspconfig.nvim",
		opts = function(_, opts)
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(event)
					local map_opts = { buffer = event.buf }

					vim.keymap.set("n", "gd", vim.lsp.buf.definition, map_opts)
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, map_opts)
					vim.keymap.set("n", "gR", vim.lsp.buf.rename, map_opts)
					vim.keymap.set({ "n", "v" }, "ga", vim.lsp.buf.code_action, map_opts)
					vim.keymap.set("n", "gr", "<CMD>Glance references<CR>")
					vim.keymap.set("n", "go", "<CMD>Glance type_definitions<CR>")
					vim.keymap.set("n", "gi", "<CMD>Glance implementations<CR>")
				end,
			})

			vim.keymap.set("n", "gl", vim.diagnostic.open_float)

			local eslint = require("efmls-configs.linters.eslint_d")
			local prettier = require("efmls-configs.formatters.prettier")
			local luacheck = require("efmls-configs.linters.luacheck")
			local stylua = require("efmls-configs.formatters.stylua")
			local gofmt = require("efmls-configs.formatters.gofmt")
			local stylelint = require("efmls-configs.linters.stylelint")
			local golangci_lint = require("efmls-configs.linters.golangci_lint")
			local autopep8 = require("efmls-configs.formatters.autopep8")
			local flake8 = require("efmls-configs.linters.flake8")
			local rubocopLint = require("efmls-configs.linters.rubocop")
			local rubocopFormat = {
				formatCommand = "bundle exec rubocop -A -f quiet --stderr -s ${INPUT}",
				formatStdin = true,
			}

			local languages = require("efmls-configs.defaults").languages()
			languages = vim.tbl_extend("force", languages, {
				-- Custom languages, or override existing ones
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
				jsonc = { prettier },
				ruby = { rubocopLint, rubocopFormat },
				lua = { luacheck, stylua },
				go = { golangci_lint, gofmt },
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
					-- capabilities = capabilities,
				})
			)

			opts.ensure_installed = { "efm" }
		end,
		dependencies = {
			{ "creativenull/efmls-configs-nvim", version = "v1.9.0" },
			{ "mason-org/mason.nvim", opts = {} },
			"neovim/nvim-lspconfig",
		},
		-- config = function()
		--
		--      -- local capabilities = vim.tbl_deep_extend(
		--      --      "force",
		--      --      vim.lsp.protocol.make_client_capabilities(),
		--      --      require("cmp_nvim_lsp").default_capabilities()
		--      -- )
		-- end,
	},
	{
		"dnlhc/glance.nvim",
		cmd = "Glance",
	},
}
