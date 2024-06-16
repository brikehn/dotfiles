local wezterm = require("wezterm")
local mux = wezterm.mux

-- Colors
local colorscheme = require("themes/rose-pine-dawn")

-- Fonts
local font = wezterm.font("JetBrainsMono Nerd Font Mono")

local harfbuzz_features = { "calt=0", "clig=0", "liga=0" } -- disable ligatures

local default_prog = { "/bin/zsh", "-l", "-c", "tmux attach || tmux" }

wezterm.on("gui-startup", function(cmd)
	local _, _, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
end)

return {
	font = font,
	font_size = 14.0,
	colors = colorscheme.colors(),
	window_frame = colorscheme.window_frame(),
	hide_tab_bar_if_only_one_tab = true,
	use_fancy_tab_bar = false,
	harfbuzz_features = harfbuzz_features,
	default_prog = default_prog,
}
