local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.vendor.ReactLua.React)

local create_element = React.createElement

local function information_text()
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
			Text = "Please do not the cat.",
			TextColor3 = Color3.fromRGB(255, 255, 255),
		},
			create_element("ImageLabel",{
				Position = UDim2.fromOffset(-30, 0),
				Size = UDim2.fromOffset(30, 30),
				BackgroundTransparency = 1,
				Image = "rbxassetid://123784732468200",
				ImageColor3 = Color3.fromRGB(255, 255, 255), -- this isn't needed, i just want to keep it consistent
			})
		)
	)
end

return information_text
