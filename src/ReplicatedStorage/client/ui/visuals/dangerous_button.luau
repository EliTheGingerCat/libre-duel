local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local button = require(script.Parent.button)

local function dangerous_button(props: { text: string?, on_activated: (() -> ())? })
	return React.createElement(button, {
		danger = true,
		text = props.text or "I agree to reset all settings.",
		on_activated = props.on_activated,
	})
end

return dangerous_button
