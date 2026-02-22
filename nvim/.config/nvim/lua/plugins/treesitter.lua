return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local languages = {
				"bash",
				"css",
				"diff",
				"dockerfile",
				"git_config",
				"git_rebase",
				"gitattributes",
				"gitcommit",
				"gitignore",
				"go",
				"gpg",
				"html",
				"javascript",
				"json",
				"jsx",
				"lua",
				"make",
				"markdown",
				"mermaid",
				"python",
				"regex",
				"ruby",
				"rust",
				"sql",
				"templ",
				"terraform",
				"tmux",
				"toml",
				"tsx",
				"typescript",
				"vim",
				"vimdoc",
				"yaml",
				"zsh",
			}
			require("nvim-treesitter").install(languages)

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("treesitter.setup", {}),
				callback = function(args)
					local buf = args.buf
					local filetype = args.match

					local language = vim.treesitter.language.get_lang(filetype) or filetype
					if not vim.treesitter.language.add(language) then
						return
					end

					vim.wo.foldmethod = "expr"
					vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"

					vim.treesitter.start(buf, language)

					vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
		end,
	},
	"nvim-treesitter/nvim-treesitter-context",
	{
		"windwp/nvim-ts-autotag",
		opts = {},
	},
}
