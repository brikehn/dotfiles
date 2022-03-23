return function()
  local lualine = safe_require("lualine")
  if not lualine then
    return
  end

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

  lualine.setup({
    options = {
      theme = "tokyonight",
      section_separators = "",
      component_separators = "",
    },
    sections = {
      lualine_a = { "" },
      lualine_b = {
        {
          "branch",
          color = { fg = "#ff9e64", bg = "#1f2335" },
        },
      },
      lualine_c = {
        {
          "filename",
          color = { fg = "#a9b1d6", bg = "#1f2335" },
        },
        {
          "diff",
          colored = true,
          diff_color = {
            added = { fg = "#9ece6a" },
            modified = { fg = "#e0af68" },
            removed = { fg = "#f7768e" },
          },
          symbols = { added = "+", modified = "~", removed = "-" },
          source = diff_source,
        },
        -- "b:gitsigns_status",
      },
      lualine_x = {
        {
          "diagnostics",
          sources = { "nvim_diagnostic" },
          symbols = { error = "E:", warn = "W:", info = "I:", hint = "H:" },
        },
      },
      lualine_y = { "" },
      lualine_z = {
        {
          "location",
          color = { fg = "#a9b1d6", bg = "#1f2335" },
        },
        {
          "progress",
          color = { fg = "#a9b1d6", bg = "#1f2335" },
        },
      },
    },
  })
end
