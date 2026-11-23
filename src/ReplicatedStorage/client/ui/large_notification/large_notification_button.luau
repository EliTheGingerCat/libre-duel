const ReplicatedStorage = game:GetService("ReplicatedStorage")

const LARGE_NOTIFICATION_LAYOUT = require(script.Parent.LARGE_NOTIFICATION_LAYOUT)
const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
const React = require(ReplicatedStorage.Packages.react)
const animated_button = require(script.Parent.Parent.components.buttons.animated_button)
const button_motion = require(script.Parent.Parent.components.buttons.button_motion)
const surface = require(script.Parent.Parent.components.controls.surface)

const create_element = React.createElement

const function large_notification_button(props: {
	text: string,
	text_colour: Color3,
	layout_order: number,
	on_activated: () -> (),
})
	return create_element(animated_button, {
		Name = "button",
		LayoutOrder = props.layout_order,
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = COLOURS.surface,
		BackgroundTransparency = 0.5,
		FontFace = FONTS.semi_bold,
		Text = props.text,
		TextColor3 = props.text_colour,
		TextSize = LARGE_NOTIFICATION_LAYOUT.TEXT_SIZE,
		[React.Event.Activated] = props.on_activated,
	}, {
		motion = create_element(button_motion),
		surface = create_element(surface, { radius = LARGE_NOTIFICATION_LAYOUT.BUTTON_CORNER_RADIUS }),
	})
end

return large_notification_button
