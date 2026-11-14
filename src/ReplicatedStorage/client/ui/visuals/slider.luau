local ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
local React = require(ReplicatedStorage.Packages.react)
local drag_detector = require(script.Parent.controls.drag_detector)
local surface = require(script.Parent.controls.surface)
local use_ui_motion = require(script.Parent.use_ui_motion)

const function slider(props: {
	value: number?,
	minimum: number?,
	maximum: number?,
	step: number?,
	text: string?,
	suffix: string?,
	on_changed: ((number) -> ())?,
	gradient: ColorSequence?,
})
	local minimum, maximum = props.minimum or 0, props.maximum or 100
	local stored, set_stored = React.useState(props.value or 50)
	local value = math.clamp(if props.on_changed then props.value or minimum else stored, minimum, maximum)
	const function change(next_value: number): ()
		local step = props.step or 1
		local rounded = math.clamp(minimum + math.round((next_value - minimum) / step) * step, minimum, maximum)
		if props.on_changed then
			props.on_changed(rounded)
		else
			set_stored(rounded)
		end
	end
	const function drag(point: Vector2): ()
		change(minimum + math.clamp(point.X, 0, 1) * (maximum - minimum))
	end
	const function key(_button: GuiButton, input: InputObject): ()
		if input.KeyCode == Enum.KeyCode.Left or input.KeyCode == Enum.KeyCode.DPadLeft then
			change(value - (props.step or 1))
		elseif input.KeyCode == Enum.KeyCode.Right or input.KeyCode == Enum.KeyCode.DPadRight then
			change(value + (props.step or 1))
		end
	end
	local motion = use_ui_motion((value - minimum) / math.max(0.001, maximum - minimum))
	const function position(amount: number): UDim2
		return UDim2.new(amount, 24 - 48 * amount, 0.5, 0)
	end
	return React.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 64),
	}, {
		label = React.createElement("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -100, 0, 32),
			Text = props.text or "UI Opacity",
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 32,
			TextColor3 = Color3.new(1, 1, 1),
			FontFace = FONTS.regular,
		}),
		value = React.createElement("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(1, -100, 0, 0),
			Size = UDim2.fromOffset(100, 32),
			Text = tostring(value) .. (props.suffix or ""),
			TextXAlignment = Enum.TextXAlignment.Right,
			TextSize = 32,
			TextColor3 = Color3.new(1, 1, 1),
			FontFace = FONTS.regular,
		}),
		input = React.createElement("TextButton", {
			Name = "slider",
			BackgroundTransparency = 1,
			Text = "",
			Position = UDim2.fromOffset(0, 32),
			Size = UDim2.new(1, 0, 0, 32),
			[React.Event.InputBegan] = key,
		}, {
			drag = React.createElement(drag_detector, { axis = Vector2.new(1, 0), on_changed = drag }),
			track = React.createElement("Frame", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0, 0.5),
				Size = UDim2.new(1, 0, 0, 10),
				BorderSizePixel = 0,
				BackgroundColor3 = if props.gradient then Color3.new(1, 1, 1) else COLOURS.surface,
				BackgroundTransparency = if props.gradient then 0 else 0.5,
			}, {
				surface = React.createElement(surface),
				gradient = props.gradient and React.createElement("UIGradient", { Color = props.gradient }),
			}),
			thumb = React.createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = motion:map(position),
				Size = UDim2.fromOffset(48, 25),
				BackgroundColor3 = Color3.new(54 / 255, 54 / 255, 54 / 255),
			}, { surface = React.createElement(surface) }),
		}),
	})
end

return slider
