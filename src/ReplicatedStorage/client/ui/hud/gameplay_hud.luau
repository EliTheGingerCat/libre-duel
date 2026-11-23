local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local builtin_hud_widget = require(script.Parent.builtin_hud_widget)
const controller_glyphs = require(script.Parent.controller_glyphs.controller_glyphs)
local editor = require(script.Parent.editor.editor)
local hud_registry = require(script.Parent.registry.hud_registry)
local touch_button = require(script.Parent.touch.touch_button)

const function cleanup()
	return hud_registry.clear_duplicates
end

const function gameplay_hud()
	React.useEffect(cleanup, {})
	local widgets = {
		editor = React.createElement(editor),
		ControllerGlyphs = React.createElement(controller_glyphs),
	}
	for _, name in { "Keystrokes", "Mousestrokes", "ReachCounter", "ComboCounter", "FpsCounter", "Paperdoll" } do
		widgets[name] = React.createElement(builtin_hud_widget, { name = name })
	end
	for _, name in { "JumpButton", "AttackButton", "UseItemButton", "InventoryButton", "TablistButton" } do
		widgets[name] = React.createElement(touch_button, { name = name })
	end
	return React.createElement(React.Fragment, {}, widgets)
end

return gameplay_hud
