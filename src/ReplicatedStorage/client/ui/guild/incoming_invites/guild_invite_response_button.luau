const ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
const React = require(ReplicatedStorage.Packages.react)
const animated_button = require(script.Parent.Parent.Parent.components.buttons.animated_button)
const button_motion = require(script.Parent.Parent.Parent.components.buttons.button_motion)
const surface = require(script.Parent.Parent.Parent.components.controls.surface)

const create_element = React.createElement

-- the accept and decline buttons on an invite card
const function guild_invite_response_button(props: {
	text: string,
	colour: Color3,
	layout_order: number,
	interactable: boolean,
	on_activated: () -> (),
})
	return create_element(animated_button, {
		Name = props.text,
		LayoutOrder = props.layout_order,
		Size = UDim2.fromOffset(0, 50),
		BackgroundColor3 = COLOURS.surface,
		BackgroundTransparency = 0.5,
		FontFace = FONTS.semi_bold,
		Text = props.text,
		TextColor3 = props.colour,
		TextSize = 24,
		Interactable = props.interactable,
		[React.Event.Activated] = props.on_activated,
	}, {
		motion = create_element(button_motion),
		surface = create_element(surface, { radius = 16, colour = props.colour }),
	})
end

return guild_invite_response_button
