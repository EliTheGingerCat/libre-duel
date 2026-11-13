const ReplicatedStorage = game:GetService("ReplicatedStorage")

const React = require(ReplicatedStorage.Packages.react)
const use_gamepad_glyph_image = require(script.Parent.use_gamepad_glyph_image)

type props = {
	key_code: Enum.KeyCode,
	size: number,
	layout_order: number?,
}

const function gamepad_glyph(props: props)
	const glyph_image = use_gamepad_glyph_image(props.key_code)

	return React.createElement("ImageLabel", {
		Name = props.key_code.Name,
		LayoutOrder = props.layout_order,
		Size = UDim2.fromOffset(props.size, props.size),
		BackgroundTransparency = 1,
		Image = glyph_image,
		ScaleType = Enum.ScaleType.Fit,
	})
end

return gamepad_glyph
