local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- appearance settings
config.color_scheme = "Catppuccin Mocha"
config.font = wezterm.font("JetBrains Mono", { weight = "Medium" })
config.font_size = 14.0
-- config.line_height = 0.9

-- window settings
config.hide_tab_bar_if_only_one_tab = true
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }

return config
