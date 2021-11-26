return function()
  local galaxyline = safe_require("galaxyline")
  local tokyonight_colors = safe_require("tokyonight.colors")
  if not galaxyline or not tokyonight_colors then
    return
  end

  local condition = require("galaxyline.condition")
  local section = require("galaxyline").section
  galaxyline.short_line_list = { "help", "NvimTree" }

  local colors = tokyonight_colors.setup()

  local alias = {
    n = "NORMAL",
    i = "INSERT",
    v = "VISUAL",
    V = "V-LINE",
    [""] = "V-BLOCK",
    R = "REPLACE",
    s = "SELECT",
    S = "S-LINE",
    [""] = "S-BLOCK",
    c = "COMMAND",
    t = "TERMINAL",
  }

  local mode_color = {
    n = colors.blue,
    no = colors.blue,
    nov = colors.blue,
    noV = colors.blue,
    i = colors.green,
    ic = colors.yellow,
    ix = colors.yellow,
    v = colors.red,
    V = colors.red,
    [""] = colors.red,
    c = colors.magenta,
    cv = colors.magenta,
    ce = colors.magenta,
    ["!"] = colors.red,
    s = colors.orange,
    S = colors.orange,
    [""] = colors.orange,
    r = colors.cyan,
    rm = colors.cyan,
    ["r?"] = colors.cyan,
    R = colors.purple,
    Rv = colors.purple,
    t = colors.purple,
  }

  section.left[1] = {
    ViMode = {
      provider = function()
        vim.cmd("hi GalaxyViMode guibg=" .. mode_color[vim.fn.mode()])
        return "  " .. alias[vim.fn.mode()] .. " "
      end,
      separator = " ",
      separator_highlight = { colors.none, colors.bg_statusline },
      highlight = { colors.black, colors.bg_statusline, "bold" },
    },
  }

  section.left[2] = {
    FileName = {
      provider = function()
        return vim.fn.expand("%:t")
      end,
      condition = condition.buffer_not_empty,
      separator = " ",
      separator_highlight = { colors.none, colors.bg_statusline },
      highlight = { colors.fg, colors.bg_statusline },
    },
  }

  section.left[3] = {
    GitBranch = {
      provider = function()
        return require("galaxyline.providers.vcs").get_git_branch()
      end,
      condition = condition.check_git_workspace,
      separator = " ",
      separator_highlight = { colors.none, colors.bg_statusline },
      highlight = { colors.orange, colors.bg_statusline },
    },
  }

  section.left[4] = {
    DiffAdd = {
      provider = "DiffAdd",
      condition = condition.hide_in_width,
      icon = "+",
      highlight = { colors.green, colors.bg_statusline },
    },
  }

  section.left[5] = {
    DiffModified = {
      provider = "DiffModified",
      condition = condition.hide_in_width,
      icon = "~",
      highlight = { colors.yellow, colors.bg_statusline },
    },
  }

  section.left[6] = {
    DiffRemove = {
      provider = "DiffRemove",
      condition = condition.hide_in_width,
      icon = "-",
      highlight = { colors.red, colors.bg_statusline },
    },
  }

  section.right[1] = {
    DiagnosticError = {
      provider = "DiagnosticError",
      icon = "E:",
      highlight = { colors.error, colors.bg_statusline },
    },
  }

  section.right[2] = {
    DiagnosticWarn = {
      provider = "DiagnosticWarn",
      icon = "W:",
      highlight = { colors.warning, colors.bg_statusline },
    },
  }

  section.right[3] = {
    DiagnosticInfo = {
      provider = "DiagnosticInfo",
      icon = "I:",
      highlight = { colors.info, colors.bg_statusline },
    },
  }

  section.right[4] = {
    DiagnosticHint = {
      provider = "DiagnosticHint",
      icon = "H:",
      highlight = { colors.hint, colors.bg_statusline },
    },
  }

  section.right[5] = {
    ShowLSP = {
      provider = "GetLspClient",
      -- condition = function()
      --   local tbl = { ['dashboard'] = true, [' '] = true }
      --   if tbl[vim.bo.filetype] then return false end
      --   return true
      -- end,
      separator = " ",
      separator_highlight = { colors.none, colors.bg_statusline },
      highlight = { colors.fg, colors.bg_statusline },
    },
  }

  section.right[6] = {
    LineInfo = {
      provider = "LineColumn",
      separator = " ",
      separator_highlight = { colors.none, colors.bg_statusline },
      highlight = { colors.fg, colors.bg_statusline },
    },
  }

  section.right[7] = {
    LinePercent = {
      provider = "LinePercent",
      highlight = { colors.fg, colors.bg_statusline },
    },
  }

  section.short_line_left[1] = {
    Spacer = {
      provider = function()
        return " "
      end,
      highlight = { colors.none, colors.bg_statusline },
    },
  }

  section.short_line_left[3] = {
    SFileName = {
      provider = function()
        return require("galaxyline.providers.fileinfo").filename_in_special_buffer()
      end,
      condition = condition.buffer_not_empty,
      highlight = { colors.fg, colors.bg_statusline },
    },
  }
end
