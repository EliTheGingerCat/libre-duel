local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.vendor.ReactLua.React)

local create_element = React.createElement

local function title_bar()
	return create_element("TextLabel",{ --titlebar
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0),
		Size = UDim2.new(1, 0, 0, 48),
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Text = "Menu",
		FontFace = Font.fromId(11702779409, Enum.FontWeight.Bold),
		TextSize = 30,
		ZIndex = 2,
	})
end

return title_bar
