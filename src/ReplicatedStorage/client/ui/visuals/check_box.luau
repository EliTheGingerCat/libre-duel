local ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
local React = require(ReplicatedStorage.Packages.react)
local animated_button = require(script.Parent.animated_button)
local button_motion = require(script.Parent.button_motion)
local surface = require(script.Parent.controls.surface)

const function check_box(props: { active: boolean?, round: boolean?, text: string?, on_changed: ((boolean) -> ())? })
	local stored, set_stored = React.useState(props.active == true)
	local active = if props.on_changed then props.active == true else stored
	const function activate(): ()
		if props.on_changed then
			props.on_changed(not active)
		else
			set_stored(not active)
		end
	end
	local control = React.createElement(animated_button, {
		Name = "checkbox",
		Size = UDim2.fromOffset(40, 40),
		BackgroundColor3 = if active
			then Color3.new(140 / 255, 140 / 255, 140 / 255)
			else COLOURS.surface,
		BackgroundTransparency = 0.5,
		Text = if active then "✓" else "",
		TextSize = 32,
		TextColor3 = Color3.new(1, 1, 1),
		FontFace = FONTS.regular,
		[React.Event.Activated] = activate,
	}, {
		surface = React.createElement(surface, { radius = if props.round then 25 else 8 }),
		motion = React.createElement(button_motion, { animate_colour = false }),
	})
	if not props.text then
		return control
	end
	return React.createElement("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40) }, {
		label = React.createElement("TextLabel", {
			Size = UDim2.new(1, -60, 1, 0),
			BackgroundTransparency = 1,
			Text = props.text,
			FontFace = FONTS.regular,
			TextSize = 32,
			TextColor3 = Color3.new(1, 1, 1),
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
		control = React.createElement("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.fromOffset(40, 40),
			BackgroundTransparency = 1,
		}, control),
	})
end

return check_box
