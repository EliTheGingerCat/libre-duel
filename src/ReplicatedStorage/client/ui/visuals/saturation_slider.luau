local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local slider = require(script.Parent.slider)

local function saturation_slider(props: { value: number?, colour: Color3?, on_changed: ((number) -> ())? })
	return React.createElement(slider, {
		text = "Saturation",
		value = props.value or 100,
		maximum = 100,
		suffix = "%",
		on_changed = props.on_changed,
		gradient = ColorSequence.new(Color3.new(0.5, 0.5, 0.5), props.colour or Color3.new(1, 0, 0)),
	})
end

return saturation_slider
