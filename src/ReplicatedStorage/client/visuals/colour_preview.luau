local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)

local create_element = React.createElement

local function colour_preview()
	return create_element("TextLabel",{
		BackgroundColor3 = Color3.fromRGB(255, 0, 0),
		Size = UDim2.new(1, 0, 0, 128),
		FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
		RichText = true,
		TextColor3 = Color3.fromRGB(255, 255, 255), --the text color should dynamically adjust based on the color, for example white color should have black text, and vice versa
		TextSize = 40,
		Text = 'Really red\n<font size="20">rgb(255, 0, 0)\nhex(FF0000)</font>',
	},
		create_element("UICorner",{
			CornerRadius = UDim.new(0, 60),
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

return colour_preview