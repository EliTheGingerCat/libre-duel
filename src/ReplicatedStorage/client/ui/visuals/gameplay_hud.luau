local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local builtin = require(script.Parent.Parent.hud.builtin)
local editor = require(script.Parent.Parent.hud.editor)
local registry = require(script.Parent.Parent.hud.registry)
local touch_button = require(script.Parent.Parent.hud.touch_button)

local function cleanup()
	return registry.clear_duplicates
end

local function gameplay_hud()
	React.useEffect(cleanup, {})
	local widgets = { editor = React.createElement(editor) }
	for _, name in { "Keystrokes", "Mousestrokes", "ReachCounter", "ComboCounter", "FpsCounter", "Paperdoll" } do
		widgets[name] = React.createElement(builtin, { name = name })
	end
	for _, name in { "JumpButton", "AttackButton", "UseItemButton", "InventoryButton", "TablistButton" } do
		widgets[name] = React.createElement(touch_button, { name = name })
	end
	return React.createElement(React.Fragment, {}, widgets)
end

return gameplay_hud
