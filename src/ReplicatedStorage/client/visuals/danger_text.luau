local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.vendor.ReactLua.React)

local create_element = React.createElement

local function danger_text()
	return create_element("Frame",{
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 32),
	},
		create_element("UIPadding",{
			PaddingLeft = UDim.new(0, 30),
		}),
		create_element("TextLabel",{
			AutomaticSize = "Y",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 32),
			FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
			TextSize = 30,
			TextXAlignment = "Left",
			Text = "You did the cat. This will have big consequences.",
			TextColor3 = Color3.fromRGB(177, 76, 78),
		},
			create_element("ImageLabel",{
				Position = UDim2.fromOffset(-30, 0),
				Size = UDim2.fromOffset(30, 30),
				BackgroundTransparency = 1,
				Image = "rbxassetid://115254390253293",
				ImageColor3 = Color3.fromRGB(177, 76, 78),
			})
		)
	)
end

return danger_text
