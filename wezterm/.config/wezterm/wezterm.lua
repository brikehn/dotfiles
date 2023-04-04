local wezterm = require("wezterm")

-- Colors
local colorscheme = require("themes/rose-pine-dawn")

-- Fonts
local font = wezterm.font("Iosevka Nerd Font Mono")

local harfbuzz_features = { "calt=0", "clig=0", "liga=0" } -- disable ligatures

return {
  font = font,
  font_size = 16.0,
  colors = colorscheme.colors(),
  window_frame = colorscheme.window_frame(),
  hide_tab_bar_if_only_one_tab = true,
  use_fancy_tab_bar = false,
  harfbuzz_features = harfbuzz_features,
}
