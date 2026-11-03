local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local alpha_grid = require(script.Parent.Parent.controls.alpha_grid)
local drag_detector = require(script.Parent.Parent.controls.drag_detector)

local function vertical_slider(props: { value: number, colour: Color3, alpha: boolean?, on_changed: (number) -> () })
	local function drag(point: Vector2): ()
		props.on_changed(1 - math.clamp((point.Y * 160 - 30) / 130, 0, 1))
	end
	local function key(_button: GuiButton, input: InputObject): ()
		if input.KeyCode == Enum.KeyCode.Up or input.KeyCode == Enum.KeyCode.DPadUp then
			props.on_changed(math.min(1, props.value + 0.01))
		elseif input.KeyCode == Enum.KeyCode.Down or input.KeyCode == Enum.KeyCode.DPadDown then
			props.on_changed(math.max(0, props.value - 0.01))
		end
	end
	return React.createElement("TextButton", {
		Name = if props.alpha then "alpha" else "brightness",
		Text = "",
		Size = UDim2.fromOffset(30, 160),
		BackgroundTransparency = 1,
		[React.Event.InputBegan] = key,
	}, {
		drag = React.createElement(drag_detector, { axis = Vector2.new(0, 1), on_changed = drag }),
		label = React.createElement("TextLabel", {
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundTransparency = 1,
			Text = tostring(math.round(props.value * 100)),
			TextSize = 24,
			TextColor3 = Color3.new(1, 1, 1),
			FontFace = Font.fromId(11702779409),
		}),
		track = React.createElement("ImageLabel", {
			Position = UDim2.fromOffset(0, 30),
			Size = UDim2.new(1, 0, 1, -30),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Image = "",
		}, {
			grid = props.alpha and React.createElement(alpha_grid),
			colour = React.createElement("Frame", {
				ZIndex = 2,
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderSizePixel = 0,
			}, {
				gradient = React.createElement("UIGradient", {
					Rotation = 90,
					Color = ColorSequence.new(props.colour, if props.alpha then props.colour else Color3.new(0, 0, 0)),
					Transparency = if props.alpha then NumberSequence.new(0, 1) else NumberSequence.new(0),
				}),
			}),
			thumb = React.createElement("Frame", {
				ZIndex = 3,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 1 - props.value),
				Size = UDim2.new(1, 5, 0, 5),
				BackgroundColor3 = Color3.new(0.5, 0.5, 0.5),
				BorderSizePixel = 2,
			}),
		}),
	})
end

return vertical_slider
