local ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
local React = require(ReplicatedStorage.Packages.react)
local gradient_stroke = require(script.Parent.Parent.visuals.gradient_stroke)
local shadow = require(script.Parent.Parent.visuals.shadow)

local create_element = React.createElement

const function counter(props: { name: string, preview: boolean? })
	return create_element("Frame", {
		Name = "Main",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = COLOURS.surface,
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
	}, {
		shadow = create_element(shadow, { ShowBehindParent = false, BlurRadius = UDim.new(0, 8), Transparency = 0.3 }),
		corner = create_element("UICorner", { CornerRadius = UDim.new(0, 24) }),
		stroke = create_element(
			gradient_stroke,
			{
				colour = Color3.new(0.86, 0.86, 0.86),
				bottom = Color3.new(0.32, 0.32, 0.32),
				rotation = -90,
				border_position = Enum.BorderStrokePosition.Inner,
			}
		),
		padding = create_element("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }),
		layout = create_element("UIListLayout", {
			Padding = UDim.new(0, 8),
			FillDirection = "Horizontal",
			HorizontalAlignment = "Left",
			VerticalAlignment = "Center",
			SortOrder = "LayoutOrder",
		}),
		icon = create_element("ImageLabel", {
			Name = "Icon",
			LayoutOrder = 1,
			Size = UDim2.fromOffset(22, 22),
			BackgroundTransparency = 1,
			Image = if props.name == "ReachCounter"
				then "rbxassetid://112495278464625"
				else "rbxassetid://127844573570900",
		}),
		text = create_element("TextLabel", {
			Name = "Text",
			LayoutOrder = 2,
			AutomaticSize = "X",
			Size = UDim2.new(0, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = if props.name == "ReachCounter"
				then "0.00 cubes"
				elseif props.name == "FpsCounter" then "0 FPS"
				else "Combo: 0",
			TextSize = 28,
			TextColor3 = Color3.new(1, 1, 1),
			FontFace = FONTS.regular,
		}),
	})
end

return counter
