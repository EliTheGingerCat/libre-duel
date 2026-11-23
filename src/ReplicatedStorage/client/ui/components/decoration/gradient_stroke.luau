local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)

local create_element = React.createElement

const function gradient_stroke(props: {
	colour: Color3?,
	bottom: Color3?,
	rotation: number?,
	border_position: Enum.BorderStrokePosition?,
})
	return create_element(
		"UIStroke",
		{
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			BorderStrokePosition = props.border_position or Enum.BorderStrokePosition.Outer,
			Color = Color3.new(1, 1, 1),
			Thickness = 1,
		},
		create_element("UIGradient", {
			Color = ColorSequence.new(
				props.colour or Color3.new(134 / 255, 134 / 255, 134 / 255),
				props.bottom or Color3.new(70 / 255, 70 / 255, 70 / 255)
			),
			Rotation = props.rotation or -90,
		})
	)
end

return gradient_stroke
