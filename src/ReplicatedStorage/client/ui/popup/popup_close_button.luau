const ReplicatedStorage = game:GetService("ReplicatedStorage")

const POPUP_LAYOUT = require(script.Parent.POPUP_LAYOUT)
const React = require(ReplicatedStorage.Packages.react)
const animated_button = require(script.Parent.Parent.visuals.animated_button)
const button_motion = require(script.Parent.Parent.visuals.button_motion)

const create_element = React.createElement

const function popup_close_button(props: { on_activated: () -> () })
	return create_element(animated_button, {
		Name = "close_button",
		class_name = "ImageButton",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -POPUP_LAYOUT.CLOSE_BUTTON_INSET, 0, POPUP_LAYOUT.CLOSE_BUTTON_INSET),
		Size = UDim2.fromOffset(POPUP_LAYOUT.CLOSE_BUTTON_SIZE, POPUP_LAYOUT.CLOSE_BUTTON_SIZE),
		ZIndex = 2,
		BackgroundTransparency = 1,
		Image = POPUP_LAYOUT.CLOSE_BUTTON_IMAGE,
		[React.Event.Activated] = props.on_activated,
	}, {
		motion = create_element(button_motion, { animate_colour = false }),
	})
end

return popup_close_button
