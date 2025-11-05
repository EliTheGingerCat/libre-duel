local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.vendor.ReactLua.React)

local create_element = React.createElement

local function saturation_slider()
	return create_element("Frame",{
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -60, 0, 32),
	},
		create_element("Frame",{ --track
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 10, 0.5, 0),
			BackgroundColor3 = Color3.fromRGB(54, 54 ,54),
			Size = UDim2.new(1, 0, 0, 10),
		},
			create_element("UICorner",{
				CornerRadius = UDim.new(1, 0),
			}),
			create_element("UIStroke",{
				Color = Color3.fromRGB(255, 255, 255),
				Thickness = 2,
			},
				create_element("UIGradient",{
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(76, 76, 76)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
					}),
				})
			),
			create_element("Frame",{ --thumb
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(1, 0.5),
				BackgroundColor3 = Color3.fromRGB(54, 54, 54),
				Size = UDim2.fromOffset(25, 25),
			},
				create_element("UICorner",{
					CornerRadius = UDim.new(1, 0),
				}),
				create_element("UIStroke",{
					Color = Color3.fromRGB(255, 255, 255),
					Thickness = 2,
				},
					create_element("UIGradient",{
						Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, Color3.fromRGB(134, 134, 134)),
							ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 70, 70)),
						}),
					})
				)
			)
		),
		create_element("TextLabel",{
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(1, 50, 0.5, 0),
			FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
			TextSize = 25,
			Text = "100", --range 0-100
			TextColor3 = Color3.fromRGB(255, 255, 255),
		})
	)
end

return saturation_slider
