local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)

local create_element = React.createElement

local function dropdown()
	return create_element("Frame",{
		AutomaticSize = "XY",
		BackgroundColor3 = Color3.fromRGB(54, 54, 54),
		Size = UDim2.fromOffset(200, 40),
	},
		create_element("TextButton",{ --title/currently selected option
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 40),
			FontFace = Font.fromId(11702779409, Enum.FontWeight.Bold),
			TextColor3 = Color3.fromRGB(177, 76, 78),
			TextSize = 32,
			Text = "Red",
		}),
		create_element("ImageButton",{ --collapse/expand button
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.fromOffset(42, 42),
			BackgroundTransparency = 1,
			Image = "rbxassetid://85332232207991",
			Rotation = 180, --set to 0 when collapsed, and 180 when expanded
		}),
		create_element("UICorner",{
			CornerRadius = UDim.new(0, 20),
		}),
		create_element("UIStroke",{ -- "Can i just have the usual" ahh uistroke 😭🙏
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
		create_element("Folder",{}, --container for the options
			create_element("UIListLayout",{}),
			create_element("Frame",{ --padding (for some reason UIPadding didn't work in this case?)
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(0, 40),
				LayoutOrder = -1, --so that it is always on top
			}),
			create_element("TextButton",{ --option
				AutomaticSize = "X",
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(200, 40),
				FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
				TextColor3 = Color3.fromRGB(177, 76, 78),
				TextSize = 32,
				Text = "Red",
			}),
			create_element("TextButton",{ --option 2
				AutomaticSize = "X",
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(200, 40),
				FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
				TextColor3 = Color3.fromRGB(13, 162, 221),
				TextSize = 32,
				Text = "Blue",
			}),
			create_element("TextButton",{ --option 3
				AutomaticSize = "X",
				BackgroundTransparency = 1,
				Size = UDim2.fromOffset(200, 40),
				FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 32,
				Text = "Spectator",
			})
		)
	)
end

return dropdown