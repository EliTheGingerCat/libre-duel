local ReplicatedStorage = game:GetService("ReplicatedStorage")

const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
local React = require(ReplicatedStorage.Packages.react)

local create_element = React.createElement

local function title_bar()
	return create_element("TextLabel", { --titlebar
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0),
		Size = UDim2.new(1, 0, 0, 48),
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Text = "Menu",
		FontFace = FONTS.bold,
		TextSize = 30,
		ZIndex = 2,
	})
end

return title_bar
