return {
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		opts = function()
			local function diff_source()
				local gitsigns = vim.b.gitsigns_status_dict
				if gitsigns then
					return {
						added = gitsigns.added,
						modified = gitsigns.changed,
						removed = gitsigns.removed,
					}
				end
			end

			return {
				options = {
					theme = "rose-pine",
					section_separators = "",
					component_separators = "",
					disabled_filetypes = { "NvimTree" },
				},
				sections = {
					lualine_a = { "" },
					lualine_b = {
						"branch",
					},
					lualine_c = {
						{
							"filename",
							path = 1,
						},
						{
							"diff",
							source = diff_source,
						},
					},
					lualine_x = {
						{
							"diagnostics",
							sources = { "nvim_lsp" },
							symbols = { error = "E:", warn = "W:", info = "I:", hint = "H:" },
						},
					},
					lualine_y = {},
					lualine_z = {
						"location",
						"progress",
					},
				},
			}
		end,
	},
}
