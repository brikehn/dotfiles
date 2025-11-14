return {
    {
	"rose-pine/neovim",
	name = "rose-pine",
	opts = {
	    dim_inactive_windows = true,
	    highlight_groups = {
		TelescopeTitle = { fg = "base", bg = "love" },
		TelescopeBorder = { fg = "overlay", bg = "overlay" },
		TelescopeNormal = { fg = "subtle", bg = "overlay" },

		TelescopeSelection = { fg = "text", bg = "highlight_med" },
		TelescopeSelectionCaret = { fg = "love", bg = "highlight_med" },
		TelescopeMultiSelection = { fg = "text", bg = "highlight_high" },

		TelescopePreviewTitle = { fg = "surface", bg = "iris" },
		TelescopePreviewNormal = { bg = "surface" },
		TelescopePreviewBorder = { fg = "surface", bg = "surface" },

		TelescopePromptTitle = { fg = "base", bg = "pine" },
		TelescopePromptNormal = { fg = "text", bg = "base" },
		TelescopePromptBorder = { fg = "base", bg = "base" },
	    },
	},
	init = function()
	    vim.opt.background = "light"
	    vim.cmd.colorscheme("rose-pine")
	end,
    },
}
