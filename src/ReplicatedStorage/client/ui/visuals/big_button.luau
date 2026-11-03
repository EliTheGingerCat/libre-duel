local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local button = require(script.Parent.button)

local function big_button(props: { text: string?, on_activated: (() -> ())? })
	return React.createElement(button, {
		large = true,
		icon = "rbxassetid://104330757164550",
		text = props.text or 'Big button\n<font color="rgb(180,180,180)" size="18">Gear icon included!</font>',
		on_activated = props.on_activated,
	})
end

return big_button
