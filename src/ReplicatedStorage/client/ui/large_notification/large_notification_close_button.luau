const ReplicatedStorage = game:GetService("ReplicatedStorage")

const LARGE_NOTIFICATION_LAYOUT = require(script.Parent.LARGE_NOTIFICATION_LAYOUT)
const React = require(ReplicatedStorage.Packages.react)
const animated_button = require(script.Parent.Parent.components.buttons.animated_button)
const button_motion = require(script.Parent.Parent.components.buttons.button_motion)

const create_element = React.createElement

const function large_notification_close_button(props: { on_activated: () -> () })
	return create_element(animated_button, {
		Name = "close_button",
		class_name = "ImageButton",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -LARGE_NOTIFICATION_LAYOUT.PADDING, 0, LARGE_NOTIFICATION_LAYOUT.PADDING),
		Size = UDim2.fromOffset(
			LARGE_NOTIFICATION_LAYOUT.CLOSE_BUTTON_SIZE,
			LARGE_NOTIFICATION_LAYOUT.CLOSE_BUTTON_SIZE
		),
		ZIndex = 2,
		BackgroundTransparency = 1,
		Image = LARGE_NOTIFICATION_LAYOUT.CLOSE_BUTTON_IMAGE,
		[React.Event.Activated] = props.on_activated,
	}, {
		motion = create_element(button_motion, { animate_colour = false }),
	})
end

return large_notification_close_button
