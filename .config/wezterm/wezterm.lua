local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.window_background_opacity = 0.85
config.hide_tab_bar_if_only_one_tab = true
config.audible_bell = "Disabled"
config.font = wezterm.font("HackGen Console NF", {weight="Regular", stretch="Normal", style="Normal"})

-- Fullscreen start
local mux = wezterm.mux
wezterm.on("gui-startup", function(cmd)
    local tab, pane, window = mux.spawn_window(cmd or {})
    window:gui_window():toggle_fullscreen()
end)

-- Shortcut keys
local act = wezterm.action
if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
config.keys = {
  {
    key = 'f',
    mods = 'CTRL|SHIFT',
    action = act.ToggleFullScreen,
  },
}
else 
config.keys = {
  {
    key = 'f',
    mods = 'CMD|CTRL',
    action = act.ToggleFullScreen,
  },
}
end


return config
