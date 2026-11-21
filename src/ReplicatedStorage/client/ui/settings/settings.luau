local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local settings_definitions = require(script.Parent.settings_definitions)
local settings_menu = require(script.Parent.settings_menu)
const use_topbar_menu_icon = require(script.Parent.Parent.topbar.use_topbar_menu_icon)

const SETTINGS_ICON = "rbxassetid://104330757164550"

settings_definitions()

const function settings()
	const menu_icon = use_topbar_menu_icon("Settings", SETTINGS_ICON)
	return React.createElement(settings_menu, { enabled = menu_icon.enabled, on_close = menu_icon.close })
end

return settings
