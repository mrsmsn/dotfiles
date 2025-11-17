local wezterm = require("wezterm")
local background_image = require("background") -- 背景用のファイルを読み込み

local config = wezterm.config_builder()

config.background = background_image

config.font_size = 11.0
config.window_background_opacity = 1
config.hide_tab_bar_if_only_one_tab = true
config.audible_bell = "Disabled"
config.window_decorations = "RESIZE" -- メニューバーを非表示
config.window_frame = {
	inactive_titlebar_bg = "none",
	active_titlebar_bg = "none",
}
config.font = wezterm.font("HackGen Console NF", {
	weight = "Regular",
	stretch = "Normal",
	style = "Normal",
})
config.window_close_confirmation = "NeverPrompt"

-- tabs settings
config.window_background_gradient = {
	colors = { "#000000" },
}
config.show_new_tab_button_in_tab_bar = false
config.show_close_tab_button_in_tabs = false
config.colors = {
	tab_bar = {
		inactive_tab_edge = "none",
	},
}
local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_upper_left_triangle

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local background = "#5c6d74"
	local foreground = "#FFFFFF"
	local edge_background = "none"
	if tab.is_active then
		background = "#1016c0"
		foreground = "#FFFFFF"
	end
	local edge_foreground = background
	local title = "   " .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. "   "
	return {
		{
			Background = {
				Color = edge_background,
			},
		},
		{
			Foreground = {
				Color = edge_foreground,
			},
		},
		{
			Text = SOLID_LEFT_ARROW,
		},
		{
			Background = {
				Color = background,
			},
		},
		{
			Foreground = {
				Color = foreground,
			},
		},
		{
			Text = title,
		},
		{
			Background = {
				Color = edge_background,
			},
		},
		{
			Foreground = {
				Color = edge_foreground,
			},
		},
		{
			Text = SOLID_RIGHT_ARROW,
		},
	}
end)

wezterm.on("gui-startup", function(cmd)
	local screen = wezterm.gui.screens().main
	local mux = wezterm.mux
	if screen.width > 3800 then
		-- Window Start for 4k
		local width_ratio = 0.5
		local height_ratio = 0.7
		local width, height = screen.width * width_ratio, screen.height * height_ratio
		local tab, pane, window = mux.spawn_window(cmd or {
			position = { x = (screen.width - width) / 2 - 10, y = (screen.height - height) / 1.2 },
		})
		window:gui_window():set_inner_size(width, height)
	else
		-- Fullscreen start
		local tab, pane, window = mux.spawn_window(cmd or {})
		window:gui_window():toggle_fullscreen()
	end
end)

-- Shortcut keys
local act = wezterm.action
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	config.wsl_domains = { {
		name = "WSL:Ubuntu",
		distribution = "Ubuntu",
		default_cwd = "~",
	} }
	config.default_domain = "WSL:Ubuntu"
	config.keys = {
		{
			key = "f",
			mods = "CTRL|SHIFT",
			action = act.ToggleFullScreen,
		},
		{
			key = "t",
			mods = "CTRL|SHIFT",
			action = wezterm.action.SpawnCommandInNewTab({
				cwd = "~",
			}),
		},
		{
			key = "w",
			mods = "CTRL|SHIFT",
			action = wezterm.action.CloseCurrentTab({
				confirm = false,
			}),
		},
	}
else
	config.macos_window_background_blur = 20
	config.keys = {
		{
			key = "f",
			mods = "CMD|SHIFT",
			action = act.ToggleFullScreen,
		},
		{
			key = "w",
			mods = "CMD|SHIFT",
			action = wezterm.action.CloseCurrentTab({
				confirm = false,
			}),
		},
	}
end

return config
