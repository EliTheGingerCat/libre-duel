local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)

local animated_button = require(script.Parent.animated_button)
local button_motion = require(script.Parent.button_motion)

local create_element = React.createElement

local function dangerous_button()
	return create_element(
		animated_button,
		{
			AutomaticSize = "X",
			BackgroundColor3 = Color3.fromRGB(17, 17, 17),
			BackgroundTransparency = 0.5,
			Size = UDim2.fromOffset(200, 50),
			FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
			TextColor3 = Color3.fromRGB(177, 76, 78),
			Text = "I agree to reset all settings.",
			TextSize = 36,
		},
		create_element(button_motion),
		create_element("UIShadow", { ShowBehindParent = false, BlurRadius = UDim.new(0, 8), Transparency = 0.3 }),
		create_element("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),
		create_element("UIPadding", {
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
		}),
		create_element(
			"UIStroke",
			{
				ApplyStrokeMode = "Border",
				Color = Color3.fromRGB(255, 255, 255),
				Thickness = 2,
			},
			create_element("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(177, 76, 78)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 70, 70)),
				}),
				Rotation = -90,
			})
		)
	)
end

return dangerous_button
