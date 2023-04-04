require("packer").startup(function(use)
	-- Packer can manage itself
	use("wbthomason/packer.nvim")

	use({
		"nvim-telescope/telescope.nvim",
		tag = "0.1.0",
		requires = { { "nvim-lua/plenary.nvim" } },
	})

	use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" })
	use("nvim-treesitter/playground")
	use("nvim-treesitter/nvim-treesitter-context")
	use("JoosepAlviste/nvim-ts-context-commentstring")
	use("windwp/nvim-ts-autotag")

	use({
		"VonHeikemen/lsp-zero.nvim",
		branch = "v2.x",
		requires = {
			-- LSP Support
			{ "neovim/nvim-lspconfig" }, -- Required
			{
				-- Optional
				"williamboman/mason.nvim",
				run = function()
					pcall(vim.cmd, "MasonUpdate")
				end,
			},
			{ "williamboman/mason-lspconfig.nvim" }, -- Optional
			{ "jose-elias-alvarez/null-ls.nvim" },
			{ "jay-babu/mason-null-ls.nvim" },

			-- Autocompletion
			{ "hrsh7th/nvim-cmp" }, -- Required
			{ "hrsh7th/cmp-nvim-lsp" }, -- Required
			{ "L3MON4D3/LuaSnip" }, -- Required
			{ "hrsh7th/cmp-buffer" },
			{ "hrsh7th/cmp-path" },
			{ "hrsh7th/cmp-nvim-lua" },
			{ "hrsh7th/cmp-nvim-lsp-signature-help" },
			{ "rafamadriz/friendly-snippets" },
			{ "saadparwaiz1/cmp_luasnip" },
		},
	})

	use("windwp/nvim-autopairs")

	use("tpope/vim-fugitive")
	use("tpope/vim-commentary")

	use("ThePrimeagen/harpoon")

	use("github/copilot.vim")

	use({
		"rose-pine/neovim",
		as = "rose-pine",
		config = function()
			vim.cmd.colorscheme("rose-pine")
		end,
	})
end)
