local ReplicatedStorage = game:GetService("ReplicatedStorage")

const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
local React = require(ReplicatedStorage.Packages.react)

local create_element = React.createElement

local function danger_text(props: { text: string? })
	return create_element(
		"Frame",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 32),
		},
		create_element("UIPadding", {
			PaddingLeft = UDim.new(0, 30),
		}),
		create_element(
			"TextLabel",
			{
				AutomaticSize = "Y",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 32),
				FontFace = FONTS.regular,
				TextSize = 30,
				TextXAlignment = "Left",
				Text = props.text or "You did the cat. This will have big consequences.",
				TextColor3 = Color3.new(1, 65 / 255, 65 / 255),
			},
			create_element("ImageLabel", {
				Position = UDim2.fromOffset(-30, 0),
				Size = UDim2.fromOffset(30, 30),
				BackgroundTransparency = 1,
				Image = "rbxassetid://115254390253293",
				ImageColor3 = Color3.new(1, 65 / 255, 65 / 255),
			})
		)
	)
end

return danger_text
