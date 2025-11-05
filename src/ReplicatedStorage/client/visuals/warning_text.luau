local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.vendor.ReactLua.React)

local create_element = React.createElement

local function warning_text()
	return create_element("Frame",{ --Warning component
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
			Text = "Please do not the cat. Final warning.",
			TextColor3 = Color3.fromRGB(255, 213, 0),
		},
			create_element("ImageLabel",{
				Position = UDim2.fromOffset(-30, 0),
				Size = UDim2.fromOffset(30, 30),
				BackgroundTransparency = 1,
				Image = "rbxassetid://97154438768583",
				ImageColor3 = Color3.fromRGB(255, 213, 0),
			})
		)
	)
end

return warning_text
