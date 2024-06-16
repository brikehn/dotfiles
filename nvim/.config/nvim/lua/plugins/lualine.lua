return {
	{
		"nvim-lualine/lualine.nvim",
		dependencies = {
			{
				"lewis6991/gitsigns.nvim",
				opts = {
					on_attach = function(bufnr)
						local gs = package.loaded.gitsigns

						local function map(mode, l, r, opts)
							opts = opts or {}
							opts.buffer = bufnr
							vim.keymap.set(mode, l, r, opts)
						end

						-- Navigation
						map("n", "]c", function()
							if vim.wo.diff then
								return "]c"
							end
							vim.schedule(function()
								gs.next_hunk()
							end)
							return "<Ignore>"
						end, { expr = true })

						map("n", "[c", function()
							if vim.wo.diff then
								return "[c"
							end
							vim.schedule(function()
								gs.prev_hunk()
							end)
							return "<Ignore>"
						end, { expr = true })

						-- Actions
						map("n", "<leader>hs", gs.stage_hunk)
						map("n", "<leader>hr", gs.reset_hunk)
						map("v", "<leader>hs", function()
							gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
						end)
						map("v", "<leader>hr", function()
							gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
						end)
						map("n", "<leader>hS", gs.stage_buffer)
						map("n", "<leader>hu", gs.undo_stage_hunk)
						map("n", "<leader>hR", gs.reset_buffer)
					end,
					current_line_blame = true,
					attach_to_untracked = true,
				},
			},
		},
		config = function()
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

			require("lualine").setup({
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
			})
		end,
	},
}
