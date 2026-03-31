local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)

local create_element = React.createElement

local colours = {
	not_active = Color3.fromRGB(54, 54, 54),
	active = Color3.fromRGB(71, 71, 71),
}

type props = {
	is_pressed: boolean?,
}

local function button(props: props)
	return create_element("TextButton",{
		AutomaticSize = "X",
		BackgroundColor3 = if props.is_pressed == true then colours.active else colours.not_active,
		Size = UDim2.fromOffset(200, 50),
		FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
		TextColor3 = Color3.fromRGB(198, 198, 198),
		Text = "Button",
		TextSize = 36,
	},
		create_element("UICorner",{
			CornerRadius = UDim.new(1, 0),
		}),
		create_element("UIPadding",{
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
		}),
		create_element("UIStroke",{
			ApplyStrokeMode = "Border",
			Color = Color3.fromRGB(255, 255, 255),
			Thickness = 2,
		},
			create_element("UIGradient",{
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(134, 134, 134)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 70, 70)),
				}),
				Rotation = -90,
			})
		)
	)
end

return button