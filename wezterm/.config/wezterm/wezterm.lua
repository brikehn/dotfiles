local wezterm = require 'wezterm'

-- Colors
local dark_colorscheme = require('themes/rose-pine')
local light_colorscheme = require('themes/rose-pine-dawn')

-- Fonts
local font = wezterm.font 'Iosevka Nerd Font Mono'
-- local font = wezterm.font 'JetBrainsMono Nerd Font Mono'

local function colorscheme_for_appearance(appearance)
  if appearance:find 'Dark' then
    return dark_colorscheme.colors(), dark_colorscheme.window_frame()
  else
    return light_colorscheme.colors(), light_colorscheme.window_frame()
  end
end

local colors, window_frame = colorscheme_for_appearance(wezterm.gui.get_appearance())

local harfbuzz_features = { "calt=0", "clig=0", "liga=0" } -- disable ligatures

return {
  font = font,
  font_size = 18.0,
  colors = colors,
  window_frame = window_frame,
  use_fancy_tab_bar = false,
  harfbuzz_features = harfbuzz_features,
}
