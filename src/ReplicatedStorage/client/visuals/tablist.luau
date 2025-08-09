local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.vendor.ReactLua.React)

local create_element = React.createElement

local function main()
	return create_element("ScreenGui",{
		ScreenInsets = "None",
        ResetOnSpawn = false,
	},
		create_element("Frame",{
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 147),
			Size = UDim2.fromOffset(720, 172),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 0.5,
		},
			create_element("TextLabel",{ -- title
				AnchorPoint = Vector2.new(0.5, 1),
				Size = UDim2.new(1, 0, 0, 40),
				Position = UDim2.fromScale(0.5, 0),
				FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
				BackgroundTransparency = 1,
				TextSize = 40,
				RichText = true,
				TextYAlignment = "Top",
				Text = '<font color="#b14c4e">Libre</font> <font color="#0da2dd">Duel</font>',
			}),
			create_element("UICorner",{
				CornerRadius = UDim.new(0, 30),
			}),
			create_element("UIPadding",{
				PaddingBottom = UDim.new(0, 40),
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
				PaddingTop = UDim.new(0, 40),
			}),
			create_element("UIStroke",{
				Thickness = 2,
				Color = Color3.fromRGB(255, 255, 255),
				ApplyStrokeMode = "Border",
			},
				create_element("UIGradient",{
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(134, 134, 134)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 70, 70)),
					}),
					Rotation = -90,
				})
			),
			create_element("Folder",{}, -- for containing the player components
				create_element("UIListLayout",{
					Padding = UDim.new(0, 10),
					FillDirection = "Horizontal",
					SortOrder = "LayoutOrder",
					Wraps = true,
				}),
				create_element("TextLabel",{ -- red player
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 0.7,
					FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
					TextColor3 = Color3.fromRGB(177, 76, 78),
					TextScaled = true,
					Size = UDim2.new(0.5, -5, 0, 38),
					TextXAlignment = "Left",
					Text = "Player1",
				},
					create_element("UIPadding",{
						PaddingLeft = UDim.new(0, 40),
						PaddingRight = UDim.new(0, 5),
					}),
					create_element("UICorner",{
						CornerRadius = UDim.new(0, 50),
					}),
					create_element("UIStroke",{
						Color = Color3.fromRGB(255, 255, 255),
						ApplyStrokeMode = "Border",
						Thickness = 2,
					},
						create_element("UIGradient",{
							Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color3.fromRGB(177, 76, 78)),
								ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 70, 70)),
							}),
							Rotation = -90,
						})
					),
					create_element("ImageLabel",{
						Position = UDim2.fromOffset(-40, 0),
						BackgroundTransparency = 1,
						Size = UDim2.fromOffset(38, 38),
						Image = "rbxassetid://94738928346033",
					},
						create_element("UICorner",{
							CornerRadius = UDim.new(1, 0),
						})
					)
				),
				create_element("TextLabel",{ -- blue player
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 0.7,
					FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
					TextColor3 = Color3.fromRGB(13, 162, 221),
					TextScaled = true,
					Size = UDim2.new(0.5, -5, 0, 38),
					TextXAlignment = "Left",
					Text = "Player2",
				},
					create_element("UIPadding",{
						PaddingLeft = UDim.new(0, 40),
						PaddingRight = UDim.new(0, 5),
					}),
					create_element("UICorner",{
						CornerRadius = UDim.new(0, 50),
					}),
					create_element("UIStroke",{
						Color = Color3.fromRGB(255, 255, 255),
						ApplyStrokeMode = "Border",
						Thickness = 2,
					},
						create_element("UIGradient",{
							Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color3.fromRGB(13, 162, 221)),
								ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 70, 70)),
							}),
							Rotation = -90,
						})
					),
					create_element("ImageLabel",{
						Position = UDim2.fromOffset(-40, 0),
						BackgroundTransparency = 1,
						Size = UDim2.fromOffset(38, 38),
						Image = "rbxassetid://94738928346033",
					},
						create_element("UICorner",{
							CornerRadius = UDim.new(1, 0),
						})
					)
				),
				create_element("TextLabel",{ -- spectator
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 0.7,
					FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
					TextColor3 = Color3.fromRGB(201, 201, 201),
					TextScaled = true,
					Size = UDim2.new(0.5, -5, 0, 38),
					TextXAlignment = "Left",
					Text = "Player3",
				},
					create_element("UIPadding",{
						PaddingLeft = UDim.new(0, 40),
						PaddingRight = UDim.new(0, 5),
					}),
					create_element("UICorner",{
						CornerRadius = UDim.new(0, 50),
					}),
					create_element("UIStroke",{
						Color = Color3.fromRGB(255, 255, 255),
						ApplyStrokeMode = "Border",
						Thickness = 2,
					},
						create_element("UIGradient",{
							Color = ColorSequence.new({
								ColorSequenceKeypoint.new(0, Color3.fromRGB(201, 201, 201)),
								ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 70, 70)),
							}),
							Rotation = -90,
						})
					),
					create_element("ImageLabel",{
						Position = UDim2.fromOffset(-40, 0),
						BackgroundTransparency = 1,
						Size = UDim2.fromOffset(38, 38),
						Image = "rbxassetid://94738928346033",
					},
						create_element("UICorner",{
							CornerRadius = UDim.new(1, 0),
						})
					)
				)
			),
			create_element("TextLabel",{ -- ping
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 1),
				FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
				TextColor3 = Color3.fromRGB(133, 221, 50),
				TextSize = 40,
				Size = UDim2.new(0.5, 0, 0, 40),
				Text = "Ping: 60ms",
			}),
			create_element("TextLabel",{ -- location
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0, 1),
				FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 40,
				Size = UDim2.new(0.5, 0, 0, 40),
				Text = "Paris, France",
			})
		)
	)
end

return main

