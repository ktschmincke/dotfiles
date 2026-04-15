local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- appearance settings
-- wezterm.gui is not available to the mux server, so take care to
-- do something reasonable when this config is evaluated by the mux
function get_appearance()
	if wezterm.gui then
		return wezterm.gui.get_appearance()
	end
	return "Dark"
end

function scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return "Catppuccin Mocha"
	else
		return "Catppuccin Latte"
	end
end

config.color_scheme = "Catppuccin Mocha"
config.font = wezterm.font("JetBrains Mono", { weight = "Medium" })
config.font_size = 14.0
-- config.line_height = 0.9

-- window settings
config.hide_tab_bar_if_only_one_tab = true
config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }

-- key bindings
config.keys = {
	-- Send distinct escape sequence for Shift+Enter (for Claude Code newlines)
	{
		key = "Enter",
		mods = "SHIFT",
		action = wezterm.action.SendString("\x1b[13;2u"),
	},
}

return config
