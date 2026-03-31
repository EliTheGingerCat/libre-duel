local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)

local create_element = React.createElement

local colours = {
	not_active = Color3.fromRGB(54, 54, 54),
	active = Color3.fromRGB(71, 71, 71),
}

type props = {
	active: boolean,
	round: boolean,
	text: string,
}

local function check_box(props: props)
	return create_element("Frame",{
		BackgroundColor3 = if props.active == true then colours.active else colours.not_active,
		Size = UDim2.fromOffset(40, 40),
	},
		create_element("UICorner",{
			CornerRadius = if props.round == true then UDim.new(1, 0) else UDim.new(0, 5),
		}),
		create_element("UIStroke",{
			ApplyStrokeMode = "Border",
			Color = Color3.fromRGB(255, 255, 255),
			Thickness = 2,
		},
			create_element("UIGradient",{
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(134, 134, 134)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 70, 70)),
				}),
				Rotation = -90,
			})
		),
		create_element("TextLabel",{
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(1, 10, 0.5, 0),
			AutomaticSize = "X",
			FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 30,
			Text = props.text,
		})
	)
end

return check_box