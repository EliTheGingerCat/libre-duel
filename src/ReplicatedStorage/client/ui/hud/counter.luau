local ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
local React = require(ReplicatedStorage.Packages.react)
local gradient_stroke = require(script.Parent.Parent.visuals.gradient_stroke)
local shadow = require(script.Parent.Parent.visuals.shadow)

local create_element = React.createElement

local function counter(props: { name: string })
	return create_element("TextLabel", {
		Name = "Main",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = COLOURS.surface,
		BackgroundTransparency = 0.4,
		BorderSizePixel = 0,
		Text = if props.name == "ReachCounter"
			then "0.00 cubes"
			elseif props.name == "FpsCounter" then "0 FPS"
			else "Combo: 0",
		TextSize = 28,
		TextColor3 = Color3.new(1, 1, 1),
		FontFace = FONTS.regular,
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
		padding = create_element("UIPadding", { PaddingLeft = UDim.new(0, 40) }),
		icon = create_element("ImageLabel", {
			Name = "Icon",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, -30, 0.5, 0),
			Size = UDim2.fromOffset(22, 22),
			BackgroundTransparency = 1,
			Image = if props.name == "ReachCounter"
				then "rbxassetid://112495278464625"
				else "rbxassetid://127844573570900",
		}),
	})
end

return counter
