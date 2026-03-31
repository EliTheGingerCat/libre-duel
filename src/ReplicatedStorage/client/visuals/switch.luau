local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)

local create_element = React.createElement

local colours = {
	active = Color3.fromRGB(76, 177, 80),
	not_active = Color3.fromRGB(177, 76, 78),
}

type props = {
	active: boolean,
}

local function switch(props: props)
	return create_element("Frame",{ --track
		BackgroundColor3 = Color3.fromRGB(54, 54, 54),
		Size = UDim2.fromOffset(64, 32),
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
		),
		create_element("Frame",{ --thumb
			AnchorPoint = if props.active == true then Vector2.new(1, 0.5) else Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(54, 54, 54),
			Position = if props.active == true then UDim2.fromScale(1, 0.5) else UDim2.fromScale(0, 0.5),
			Size = UDim2.fromOffset(30, 30),
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
						ColorSequenceKeypoint.new(0, if props.active == true then colours.active else colours.not_active),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 70, 70)),
					}),
				})
			)
		)
	)
end

return switch