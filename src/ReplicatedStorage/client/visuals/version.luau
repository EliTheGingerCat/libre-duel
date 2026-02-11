local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.vendor.ReactLua.React)

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
				Position = UDim2.new(0, 10, 1, 0),
				Size = UDim2.fromOffset(320, 50),
				Text = "Libre Duel — Pre-release",
				TextColor3 = Color3.new(1, 1, 1),
				TextSize = 20,
				TextXAlignment = Enum.TextXAlignment.Left
			},
			create_element(
				"UIStroke",
				{
					Color = Color3.new(0, 0, 0),
					Thickness = 2
				}
			)
		)
	)
end

return main