local ReplicatedStorage = game:GetService("ReplicatedStorage")

const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
local React = require(ReplicatedStorage.Packages.react)

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
local create_element = React.createElement

const function version()
	return create_element(
		"ScreenGui",
		{
			Name = "Version",
			ResetOnSpawn = false,
		},
		create_element(
			"TextLabel",
			{
				AnchorPoint = Vector2.new(0, 1),
				BackgroundTransparency = 1,
				FontFace = FONTS.regular,
				Position = UDim2.new(0, 10, 1, 0),
				Size = UDim2.fromOffset(320, 50),
				Text = "Libre Duel — Pre-release",
				TextColor3 = COLOURS.white,
				TextSize = 20,
				TextXAlignment = Enum.TextXAlignment.Left,
			},
			create_element("UIStroke", {
				Color = COLOURS.white,
				Thickness = 0.1,
			}),
			create_element("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, COLOURS.light_grey),
					ColorSequenceKeypoint.new(1, COLOURS.dark_grey),
				}),
				Rotation = -90,
			})
		)
	)
end

return version
