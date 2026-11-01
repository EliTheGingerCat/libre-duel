local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local gradient_stroke = require(script.Parent.Parent.visuals.gradient_stroke)

local create_element = React.createElement

local function key(props: { name: string, position: Vector2 })
	return create_element("TextLabel", {
		Name = props.name,
		Position = UDim2.fromOffset(props.position.X, props.position.Y),
		Size = UDim2.fromOffset(48, 48),
		BackgroundColor3 = Color3.new(17 / 255, 17 / 255, 17 / 255),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Text = props.name,
		TextSize = 38,
		TextColor3 = Color3.new(1, 1, 1),
		FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
	}, {
		corner = create_element("UICorner", {
			TopLeftRadius = UDim.new(0, if props.name == "W" or props.name == "A" then 16 else 0),
			TopRightRadius = UDim.new(0, if props.name == "W" or props.name == "D" then 16 else 0),
			BottomLeftRadius = UDim.new(0, 0),
			BottomRightRadius = UDim.new(0, 0),
		}),
		stroke = create_element(
			gradient_stroke,
			{
				colour = Color3.new(0.86, 0.86, 0.86),
				bottom = Color3.new(0.32, 0.32, 0.32),
				rotation = -90,
				border_position = Enum.BorderStrokePosition.Inner,
			}
		),
	})
end

local function keystrokes()
	return create_element(React.Fragment, {}, {
		W = create_element(key, { name = "W", position = Vector2.new(52, 0) }),
		A = create_element(key, { name = "A", position = Vector2.new(0, 52) }),
		S = create_element(key, { name = "S", position = Vector2.new(52, 52) }),
		D = create_element(key, { name = "D", position = Vector2.new(104, 52) }),
		Space = create_element("Frame", {
			Position = UDim2.fromOffset(0, 103),
			Size = UDim2.fromOffset(152, 34),
			BackgroundColor3 = Color3.new(17 / 255, 17 / 255, 17 / 255),
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
		}, {
			corner = create_element("UICorner", {
				TopLeftRadius = UDim.new(0, 0),
				TopRightRadius = UDim.new(0, 0),
				BottomLeftRadius = UDim.new(0, 24),
				BottomRightRadius = UDim.new(0, 24),
			}),
			stroke = create_element(
				gradient_stroke,
				{
					colour = Color3.new(0.86, 0.86, 0.86),
					bottom = Color3.new(0.32, 0.32, 0.32),
					rotation = -90,
					border_position = Enum.BorderStrokePosition.Inner,
				}
			),
			Dash = create_element("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(114, 6),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderSizePixel = 0,
			}, create_element("UICorner", { CornerRadius = UDim.new(1, 0) })),
		}),
	})
end

return keystrokes
