local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)

const function alpha_grid(props: { radius: number?, children: unknown? })
	return React.createElement("ImageLabel", {
		Name = "alpha_grid",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		Image = "rbxassetid://130003058649427",
		ScaleType = Enum.ScaleType.Tile,
		TileSize = UDim2.fromOffset(16, 16),
		ResampleMode = Enum.ResamplerMode.Pixelated,
	}, {
		corner = props.radius and React.createElement("UICorner", { CornerRadius = UDim.new(0, props.radius) }),
		content = React.createElement(React.Fragment, {}, props.children),
	})
end

return alpha_grid
