const ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
const POPUP_LAYOUT = require(script.Parent.Parent.POPUP_LAYOUT)
const React = require(ReplicatedStorage.Packages.react)
const animated_button = require(script.Parent.Parent.Parent.components.buttons.animated_button)
const button_motion = require(script.Parent.Parent.Parent.components.buttons.button_motion)
const popup_button_hold_progress = require(script.Parent.popup_button_hold_progress)
const popup_types = require(ReplicatedStorage.shared.popup.popup_types)
const surface = require(script.Parent.Parent.Parent.components.controls.surface)

const create_element = React.createElement

-- greys keep the default grey stroke, a white stroke looks way too loud
const function get_stroke_colour(colour: Color3): Color3?
	if colour.R == colour.G and colour.G == colour.B then
		return nil
	end
	return colour
end

const function popup_button(props: {
	button: popup_types.popup_button,
	layout_order: number,
	on_pressed: () -> (),
})
	const colour = props.button.colour
	const hold_time = props.button.button_progress_time
	const needs_hold = hold_time ~= nil and hold_time > 0

	return create_element(animated_button, {
		Name = "button",
		LayoutOrder = props.layout_order,
		Size = UDim2.new(1, 0, 0, POPUP_LAYOUT.ROW_HEIGHT),
		BackgroundColor3 = COLOURS.surface,
		BackgroundTransparency = 0.5,
		FontFace = FONTS.semi_bold,
		Text = props.button.text,
		TextColor3 = colour,
		TextSize = POPUP_LAYOUT.TEXT_SIZE,
		[React.Event.Activated] = if needs_hold then nil else props.on_pressed,
	}, {
		motion = create_element(button_motion),
		surface = create_element(surface, {
			radius = POPUP_LAYOUT.ROW_CORNER_RADIUS,
			colour = get_stroke_colour(colour),
		}),
		progress = if needs_hold
			then create_element(popup_button_hold_progress, {
				colour = colour,
				hold_time = hold_time :: number,
				on_completed = props.on_pressed,
			})
			else nil,
	})
end

return popup_button
