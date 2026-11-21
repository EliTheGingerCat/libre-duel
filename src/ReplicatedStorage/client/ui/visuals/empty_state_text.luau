const ReplicatedStorage = game:GetService("ReplicatedStorage")

const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
const React = require(ReplicatedStorage.Packages.react)

const EMPTY_STATE_COLOUR = Color3.fromRGB(200, 200, 200)

-- faint centred line for lists with nothing in them, so they don't look broken
const function empty_state_text(props: { text: string, text_size: number?, layout_order: number? })
	return React.createElement("TextLabel", {
		Name = "empty",
		LayoutOrder = props.layout_order,
		Size = UDim2.new(1, 0, 0, 64),
		BackgroundTransparency = 1,
		FontFace = FONTS.regular,
		Text = props.text,
		TextSize = props.text_size or 24,
		TextColor3 = EMPTY_STATE_COLOUR,
		TextWrapped = true,
	})
end

return empty_state_text
