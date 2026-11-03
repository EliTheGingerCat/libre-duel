local ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
local React = require(ReplicatedStorage.Packages.react)
local animated_button = require(script.Parent.animated_button)
local button_motion = require(script.Parent.button_motion)
local surface = require(script.Parent.controls.surface)

local function button(props: {
	text: string?,
	on_activated: (() -> ())?,
	size: UDim2?,
	danger: boolean?,
	large: boolean?,
	icon: string?,
})
	local large = props.large
	return React.createElement(animated_button, {
		Name = "button",
		AutomaticSize = if large then Enum.AutomaticSize.None else Enum.AutomaticSize.X,
		BackgroundColor3 = COLOURS.surface,
		BackgroundTransparency = 0.5,
		Size = props.size or (if large then UDim2.new(1, 0, 0, 128) else UDim2.fromOffset(200, 50)),
		FontFace = FONTS.regular,
		TextColor3 = if props.danger then COLOURS.danger else Color3.new(1, 1, 1),
		Text = props.text or "Button",
		RichText = true,
		TextSize = 36,
		[React.Event.Activated] = props.on_activated,
	}, {
		motion = React.createElement(button_motion),
		surface = React.createElement(surface, { radius = if large then 60 else 25, danger = props.danger }),
		padding = React.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 20),
			PaddingRight = UDim.new(0, 20),
		}),
		icon = props.icon and React.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 14, 0.5, 0),
			Size = UDim2.fromOffset(100, 100),
			BackgroundTransparency = 1,
			Image = props.icon,
			ImageColor3 = Color3.new(0.5, 0.5, 0.5),
		}),
	})
end

return button
