local ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
local React = require(ReplicatedStorage.Packages.react)
local gradient_stroke = require(script.Parent.Parent.visuals.gradient_stroke)
local shadow = require(script.Parent.Parent.visuals.shadow)

local create_element = React.createElement

const function mouse_button(props: { name: string, x: number })
	return create_element(
		"TextLabel",
		{
			Position = UDim2.fromOffset(props.x, 122),
			Size = UDim2.fromOffset(112, 36),
			BackgroundColor3 = COLOURS.surface,
			BackgroundTransparency = 0.4,
			BorderSizePixel = 0,
			Text = props.name,
			TextSize = 32,
			TextColor3 = Color3.new(1, 1, 1),
			FontFace = FONTS.regular,
		},
		create_element("UICorner", {
			TopLeftRadius = UDim.new(0, 0),
			TopRightRadius = UDim.new(0, 0),
			BottomLeftRadius = UDim.new(0, if props.x == 0 then 24 else 0),
			BottomRightRadius = UDim.new(0, if props.x == 112 then 28 else 0),
		})
	)
end

const function mousestrokes(props: { preview: boolean? })
	return create_element(React.Fragment, {}, {
		Top = create_element("ImageLabel", {
			Size = UDim2.fromOffset(224, 122),
			BackgroundColor3 = COLOURS.surface,
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
			Image = "rbxassetid://121854981390576",
			ImageTransparency = 0.5,
			ScaleType = Enum.ScaleType.Tile,
			TileSize = UDim2.fromOffset(32, 32),
		}, {
			corner = create_element("UICorner", {
				TopLeftRadius = UDim.new(0, 24),
				TopRightRadius = UDim.new(0, 24),
				BottomLeftRadius = UDim.new(0, 0),
				BottomRightRadius = UDim.new(0, 0),
			}),
			gradient = create_element(
				"UIGradient",
				{ Color = ColorSequence.new(Color3.new(184 / 255, 184 / 255, 184 / 255), Color3.new(1, 1, 1)) }
			),
			Point = create_element("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(12, 12),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BorderSizePixel = 0,
			}, create_element("UICorner", { CornerRadius = UDim.new(1, 0) })),
		}),
		Lmb = create_element(mouse_button, { name = "Left", x = 0 }),
		Rmb = create_element(mouse_button, { name = "Right", x = 112 }),
		Stroke = create_element("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ZIndex = 2,
		}, {
			corner = create_element("UICorner", { CornerRadius = UDim.new(0, 24) }),
			shadow = create_element(shadow, { ShowBehindParent = false, BlurRadius = UDim.new(0, 8), Transparency = 0.3 }),
			stroke = create_element(
				gradient_stroke,
				{
					colour = Color3.new(0.86, 0.86, 0.86),
					bottom = Color3.new(0.32, 0.32, 0.32),
					rotation = -90,
					border_position = Enum.BorderStrokePosition.Inner,
				}
			),
		}),
	})
end

return mousestrokes
