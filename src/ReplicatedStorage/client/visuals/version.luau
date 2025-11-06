local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.vendor.ReactLua.React)

local colours = require(ReplicatedStorage.modules.colours)
local create_element = React.createElement

local function main()
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
				FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
				Position = UDim2.new(0, 10, 1, 0),
				Size = UDim2.fromOffset(320, 50),
				Text = "Libre Duel — Pre-release",
				TextColor3 = colours["white"],
				TextSize = 20,
				TextXAlignment = Enum.TextXAlignment.Left
			},
			create_element(
				"UIStroke",
				{
					Color = colours["white"],
					Thickness = 2
				}
			)
		)
	)
end

return main
