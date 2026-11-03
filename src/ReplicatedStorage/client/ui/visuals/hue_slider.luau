local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local slider = require(script.Parent.slider)

local function hue_slider(props: { value: number?, colour: Color3?, on_changed: ((number) -> ())? })
	return React.createElement(slider, {
		text = "Hue",
		value = props.value or 0,
		maximum = 360,
		suffix = "°",
		on_changed = props.on_changed,
		gradient = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
			ColorSequenceKeypoint.new(1 / 6, Color3.new(1, 1, 0)),
			ColorSequenceKeypoint.new(2 / 6, Color3.new(0, 1, 0)),
			ColorSequenceKeypoint.new(3 / 6, Color3.new(0, 1, 1)),
			ColorSequenceKeypoint.new(4 / 6, Color3.new(0, 0, 1)),
			ColorSequenceKeypoint.new(5 / 6, Color3.new(1, 0, 1)),
			ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0)),
		}),
	})
end

return hue_slider
