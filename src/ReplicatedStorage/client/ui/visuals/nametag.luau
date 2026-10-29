local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)

local create_element = React.createElement

const PADDING_CHARACTER = "  "

local function nametag(props: {
	adornee: BasePart | Attachment,
	extra_text: string,
	name: string,
})
	return create_element(
		"BillboardGui",
		{
			Active = true,
			Adornee = props.adornee,
			AlwaysOnTop = true,
			ClipsDescendants = false,
			ExtentsOffsetWorldSpace = Vector3.new(0, 4, 0),
			LightInfluence = 0,
			Name = "Nametag",
			Size = UDim2.fromScale(32, 1.5),
			ZIndexBehavior = "Sibling",
		},
		create_element(
			"TextLabel",
			{
				AnchorPoint = Vector2.new(0.5, 1),
				AutomaticSize = "X",
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 0.5,
				BorderSizePixel = 0,
				FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
				Name = "Name",
				Position = UDim2.fromScale(0.5, 1),
				Size = UDim2.fromScale(0, 0.6),
				Text = `{PADDING_CHARACTER}{props.name}{PADDING_CHARACTER}`,
				TextColor3 = Color3.fromRGB(0, 255, 225),
				TextScaled = true,
				TextSize = 100,
				TextWrapped = true,
				TextXAlignment = "Center",
				TextYAlignment = "Center",
			},
			create_element("UICorner", {
				CornerRadius = UDim.new(1, 0),
			}),
			create_element(
				"UIStroke",
				{
					ApplyStrokeMode = "Border",
					Color = Color3.fromRGB(255, 255, 255),
					StrokeSizingMode = "ScaledSize",
					Thickness = 0.04,
				},
				create_element("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 255, 216)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
					}),
					Rotation = -90,
				})
			),
			create_element("UISizeConstraint", {
				-- this is because textscaled stops growing at 100, so let's cap the background height with it
				MaxSize = Vector2.new(math.huge, 100),
			})
		),
		create_element("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
			Name = "ExtraText",
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.fromScale(1, 0.4),
			Text = props.extra_text,
			TextColor3 = Color3.fromRGB(255, 53, 53),
			TextScaled = true,
			TextSize = 40,
			TextWrapped = true,
			TextXAlignment = "Center",
			TextYAlignment = "Bottom",
		})
	)
end

return nametag
