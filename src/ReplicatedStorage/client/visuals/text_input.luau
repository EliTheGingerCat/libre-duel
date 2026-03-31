local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)

local create_element = React.createElement

local function text_input()
	return create_element("TextBox",{
		ClearTextOnFocus = false,
		BackgroundColor3 = Color3.fromRGB(54, 54, 54),
		Size = UDim2.new(1, 0, 0, 50),
		FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
		PlaceholderColor3 = Color3.fromRGB(129, 129, 129),
		PlaceholderText = "Enter text...",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 50,
		Text = "",
		TextXAlignment = "Left",
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

return text_input
