local ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
local React = require(ReplicatedStorage.Packages.react)
local animated_button = require(script.Parent.animated_button)
local button_motion = require(script.Parent.button_motion)
local surface = require(script.Parent.controls.surface)

const function button(props: {
	text: string?,
	on_activated: (() -> ())?,
	size: UDim2?,
	danger: boolean?,
	large: boolean?,
	icon: string?,
	colour: Color3?,
	radius: number?,
	interactable: boolean?,
})
	local large = props.large
	local inline_icon = props.icon ~= nil and not large
	local text = props.text or "Button"
	local text_colour = props.colour or (if props.danger then COLOURS.danger else Color3.new(1, 1, 1))
	return React.createElement(animated_button, {
		Name = "button",
		AutomaticSize = if large or inline_icon then Enum.AutomaticSize.None else Enum.AutomaticSize.X,
		BackgroundColor3 = COLOURS.surface,
		BackgroundTransparency = 0.5,
		Size = props.size or (if large then UDim2.new(1, 0, 0, 128) else UDim2.fromOffset(200, 50)),
		FontFace = FONTS.regular,
		TextColor3 = text_colour,
		Text = if inline_icon then "" else text,
		RichText = true,
		TextSize = 36,
		Interactable = props.interactable,
		[React.Event.Activated] = props.on_activated,
	}, {
		motion = React.createElement(button_motion),
		surface = React.createElement(
			surface,
			{ radius = props.radius or (if large then 60 else 25), danger = props.danger, colour = props.colour }
		),
		padding = React.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 20),
			PaddingRight = UDim.new(0, 20),
		}),
		icon = large and props.icon and React.createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 14, 0.5, 0),
			Size = UDim2.fromOffset(100, 100),
			BackgroundTransparency = 1,
			Image = props.icon,
			ImageColor3 = props.colour or Color3.new(0.5, 0.5, 0.5),
		}),
		-- Centres the icon and text as one group, so the button stays balanced.
		inline = inline_icon and React.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
		}, {
			layout = React.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 12),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			icon = React.createElement("ImageLabel", {
				LayoutOrder = 1,
				Size = UDim2.fromScale(0.6, 0.6),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				BackgroundTransparency = 1,
				Image = props.icon,
				ImageColor3 = props.colour or Color3.new(0.5, 0.5, 0.5),
			}),
			label = React.createElement("TextLabel", {
				LayoutOrder = 2,
				AutomaticSize = Enum.AutomaticSize.X,
				Size = UDim2.fromScale(0, 1),
				BackgroundTransparency = 1,
				FontFace = FONTS.regular,
				RichText = true,
				Text = text,
				TextColor3 = text_colour,
				TextSize = 36,
			}),
		}),
	})
end

return button
