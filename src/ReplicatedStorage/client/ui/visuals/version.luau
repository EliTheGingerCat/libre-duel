local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local ReactRoblox = require(ReplicatedStorage.Packages["react-roblox"])

local colours = require(ReplicatedStorage.shared.ui.colours)
local create_element = React.createElement

local function version()
	return create_element("ScreenGui", {
		Name = "Version",
		ResetOnSpawn = false,
	},
		create_element("TextLabel", {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = 1,
			FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
			Position = UDim2.new(0, 10, 1, 0),
			Size = UDim2.fromOffset(320, 50),
			Text = "Libre Duel — Pre-release",
			TextColor3 = colours.white,
			TextSize = 20,
			TextXAlignment = Enum.TextXAlignment.Left
		},
			create_element("UIStroke", {
				Color = colours.white,
				Thickness = 0.1
			}),
			create_element("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, colours.light_grey),
					ColorSequenceKeypoint.new(1, colours.dark_grey),
				}),
				Rotation = -90,
			})
		)
	)
end

return version
