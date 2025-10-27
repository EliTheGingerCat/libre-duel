local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.vendor.ReactLua.React)

local create_element = React.createElement

local function main()
	return create_element("ScreenGui",{
		Enabled = false, -- disabled because only HUD elements should be visible all the time, these belong in menus and such
	},
		create_element("Frame",{
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(35, 35, 35),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(1366, 768),
		},
			create_element("UICorner",{
				CornerRadius = UDim.new(0, 65),
			}),
			create_element("UIStroke",{
				Color = Color3.fromRGB(255, 255, 255), --i think fromRGB should be the Standard.
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
			create_element("ImageButton",{ --closing button
				BackgroundTransparency = 1,
				Position = UDim2.new(1, -80, 0, 5),
				Size = UDim2.fromOffset(42, 42),
				Image = "rbxassetid://72160170469319",
				ZIndex = 2,
			}),
			create_element("TextLabel",{ --titlebar
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundTransparency = 1,
				Position = UDim2.fromScale(0.5, 0),
				Size = UDim2.new(1, 0, 0, 48),
				TextColor3 = Color3.fromRGB(255, 255, 255),
				Text = "Menu",
				FontFace = Font.fromId(11702779409, Enum.FontWeight.Bold),
				TextSize = 30,
				ZIndex = 2,
			}),
			create_element("Frame",{ --container
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromRGB(47, 47, 47),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.new(1, -10, 1, -10),
			},
				create_element("UICorner",{
					CornerRadius = UDim.new(0, 60),
				}),
				create_element("UIStroke",{
				Color = Color3.fromRGB(255, 255, 255), --i think fromRGB should be the Standard.
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
				create_element("CanvasGroup",{
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
				},
					create_element("UICorner",{
						CornerRadius = UDim.new(0, 55),
					}),
					create_element("ScrollingFrame",{
						AnchorPoint = Vector2.new(0.5, 1),
						BackgroundTransparency = 1,
						Position = UDim2.fromScale(0.5, 1),
						Size = UDim2.new(1, -20, 1, -48),
						ClipsDescendants = true,
						ScrollBarThickness = 0,
					},
						create_element("UIListLayout",{
							SortOrder = "LayoutOrder",
							Padding = UDim.new(0, 20),
						}),
						create_element("UIPadding",{
							PaddingBottom = UDim.new(0, 5),
							PaddingLeft = UDim.new(0, 10),
							PaddingRight = UDim.new(0, 10),
							PaddingTop = UDim.new(0, 5),
						}),

--[[

here come the Juicy stuff..

]]

--[[
information text
]]
						create_element("Frame",{
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 32),
						},
							create_element("UIPadding",{
								PaddingLeft = UDim.new(0, 30),
							}),
							create_element("TextLabel",{
								AutomaticSize = "Y",
								BackgroundTransparency = 1,
								Size = UDim2.new(1, 0, 0, 32),
								FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
								TextSize = 30,
								TextXAlignment = "Left",
								Text = "Please do not the cat.",
								TextColor3 = Color3.fromRGB(255, 255, 255),
							},
								create_element("ImageLabel",{
									Position = UDim2.fromOffset(-30, 0),
									Size = UDim2.fromOffset(30, 30),
									BackgroundTransparency = 1,
									Image = "rbxassetid://123784732468200",
									ImageColor3 = Color3.fromRGB(255, 255, 255), -- this isn't needed, i just want to keep it consistent
								})
							)
						),
--[[
warning text
]]
						create_element("Frame",{ --Warning component
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 32),
						},
							create_element("UIPadding",{
								PaddingLeft = UDim.new(0, 30),
							}),
							create_element("TextLabel",{
								AutomaticSize = "Y",
								BackgroundTransparency = 1,
								Size = UDim2.new(1, 0, 0, 32),
								FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
								TextSize = 30,
								TextXAlignment = "Left",
								Text = "Please do not the cat. Final warning.",
								TextColor3 = Color3.fromRGB(255, 213, 0),
							},
								create_element("ImageLabel",{
									Position = UDim2.fromOffset(-30, 0),
									Size = UDim2.fromOffset(30, 30),
									BackgroundTransparency = 1,
									Image = "rbxassetid://97154438768583",
									ImageColor3 = Color3.fromRGB(255, 213, 0),
								})
							)
						),
--[[
danger text
]]
						create_element("Frame",{
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 32),
						},
							create_element("UIPadding",{
								PaddingLeft = UDim.new(0, 30),
							}),
							create_element("TextLabel",{
								AutomaticSize = "Y",
								BackgroundTransparency = 1,
								Size = UDim2.new(1, 0, 0, 32),
								FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
								TextSize = 30,
								TextXAlignment = "Left",
								Text = "You did the cat. This will have big consequences.",
								TextColor3 = Color3.fromRGB(177, 76, 78),
							},
								create_element("ImageLabel",{
									Position = UDim2.fromOffset(-30, 0),
									Size = UDim2.fromOffset(30, 30),
									BackgroundTransparency = 1,
									Image = "rbxassetid://115254390253293",
									ImageColor3 = Color3.fromRGB(177, 76, 78),
								})
							)
						),
--[[
text input
]]
						create_element("TextBox",{
							ClearTextOnFocus = false,
							BackgroundColor3 = Color3.fromRGB(54, 54, 54),
							Size = UDim2.new(1, 0, 0, 50),
							FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
							PlaceholderColor3 = Color3.fromRGB(129, 129, 129),
							PlaceholderText = "Enter text...",
							TextColor3 = Color3.fromRGB(255, 255, 255),
							TextSize = 50,
							Text = "",
							TextXAlignment = "Left",
						},
							create_element("UICorner",{
								CornerRadius = UDim.new(1, 0),
							}),
							create_element("UIPadding",{
								PaddingLeft = UDim.new(0, 10),
								PaddingRight = UDim.new(0, 10),
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
							)
						),
--[[
slider
]]
						create_element("Frame",{
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
											ColorSequenceKeypoint.new(0, Color3.fromRGB(134, 134, 134)),
											ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 70, 70)),
										}),
									})
								),
								create_element("Frame",{ --thumb
									AnchorPoint = Vector2.new(0.5, 0.5),
									Position = UDim2.fromScale(0, 0.5),
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
								Text = "100", --any range
								TextColor3 = Color3.fromRGB(255, 255, 255),
							})
						),
--[[
hue slider
]]
						create_element("Frame",{
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
											ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
											ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
											ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
											ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
											ColorSequenceKeypoint.new(0.666666, Color3.fromRGB(0, 0, 255)),
											ColorSequenceKeypoint.new(0.833333, Color3.fromRGB(255, 0, 255)),
											ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
										}),
									})
								),
								create_element("Frame",{ --thumb
									AnchorPoint = Vector2.new(0.5, 0.5),
									Position = UDim2.fromScale(0, 0.5),
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
								Text = "0", --range 0-360
								TextColor3 = Color3.fromRGB(255, 255, 255),
							})
						),
--[[
saturation slider
]]
						create_element("Frame",{
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
						),
--[[
value slider
]]
						create_element("Frame",{
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
											ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
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
						),
--[[
color preview
]]
						create_element("TextLabel",{
							BackgroundColor3 = Color3.fromRGB(255, 0, 0),
							Size = UDim2.new(1, 0, 0, 128),
							FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
							RichText = true,
							TextColor3 = Color3.fromRGB(255, 255, 255), --the text color should dynamically adjust based on the color, for example white color should have black text, and vice versa
							TextSize = 40,
							Text = 'Really red\n<font size="20">rgb(255, 0, 0)\nhex(FF0000)</font>',
						},
							create_element("UICorner",{
								CornerRadius = UDim.new(0, 60),
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
							)
						),
--[[
button
]]
						create_element("TextButton",{
							AutomaticSize = "X",
							BackgroundColor3 = Color3.fromRGB(54, 54, 54),
							Size = UDim2.fromOffset(200, 50),
							FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
							TextColor3 = Color3.fromRGB(198, 198, 198),
							Text = "Button",
							TextSize = 36,
						},
							create_element("UICorner",{
								CornerRadius = UDim.new(1, 0),
							}),
							create_element("UIPadding",{
								PaddingLeft = UDim.new(0, 10),
								PaddingRight = UDim.new(0, 10),
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
							)
						),
--[[
active/pressed button
]]
						create_element("TextButton",{
							AutomaticSize = "X",
							BackgroundColor3 = Color3.fromRGB(71, 71, 71),
							Size = UDim2.fromOffset(200, 50),
							FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
							TextColor3 = Color3.fromRGB(198, 198, 198),
							Text = "Button",
							TextSize = 36,
						},
							create_element("UICorner",{
								CornerRadius = UDim.new(1, 0),
							}),
							create_element("UIPadding",{
								PaddingLeft = UDim.new(0, 10),
								PaddingRight = UDim.new(0, 10),
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
							)
						),
--[[
dangerous button
]]
						create_element("TextButton",{
							AutomaticSize = "X",
							BackgroundColor3 = Color3.fromRGB(54, 54, 54),
							Size = UDim2.fromOffset(200, 50),
							FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
							TextColor3 = Color3.fromRGB(177, 76, 78),
							Text = "I agree to reset all settings.",
							TextSize = 36,
						},
							create_element("UICorner",{
								CornerRadius = UDim.new(1, 0),
							}),
							create_element("UIPadding",{
								PaddingLeft = UDim.new(0, 10),
								PaddingRight = UDim.new(0, 10),
							}),
							create_element("UIStroke",{
								ApplyStrokeMode = "Border",
								Color = Color3.fromRGB(255, 255, 255),
								Thickness = 2,
							},
								create_element("UIGradient",{
									Color = ColorSequence.new({
										ColorSequenceKeypoint.new(0, Color3.fromRGB(177, 76, 78)),
										ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 70, 70)),
									}),
									Rotation = -90,
								})
							)
						),
--[[
big button
]]
						create_element("TextButton",{
							AutomaticSize = "X",
							BackgroundColor3 = Color3.fromRGB(54, 54, 54),
							Size = UDim2.new(1, 0, 0, 128),
							FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
							TextColor3 = Color3.fromRGB(255, 255, 255),
							RichText = true,
							Text = 'Big button\n<font color="rgb(180,180,180)"><font size="18">Gear icon included!</font></font>',
							TextSize = 36,
						},
							create_element("UICorner",{
								CornerRadius = UDim.new(0, 60),
							}),
							create_element("UIPadding",{
								PaddingLeft = UDim.new(0, 10),
								PaddingRight = UDim.new(0, 10),
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
							create_element("ImageLabel",{ --icon
								AnchorPoint = Vector2.new(0, 0.5),
								BackgroundTransparency = 1,
								Position = UDim2.new(0, 14, 0.5, 0),
								Size = UDim2.fromOffset(100, 100),
								Image = "rbxassetid://104330757164550",
							},
								create_element("UIGradient",{
									Color = ColorSequence.new({
										ColorSequenceKeypoint.new(0, Color3.fromRGB(134, 134, 134)),
										ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 70, 70)),
									}),
									Rotation = -90,
								})
							)
						),
--[[
multi select [square] checkbox
]]
						create_element("Frame",{
							BackgroundColor3 = Color3.fromRGB(54, 54, 54),
							Size = UDim2.fromOffset(40, 40),
						},
							create_element("UICorner",{
								CornerRadius = UDim.new(0, 5),
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
								Text = "Blud didnt select ts.. 💔",
							})
						),
--[[
actve/selected multi select [square] checkbox
]]
						create_element("Frame",{
							BackgroundColor3 = Color3.fromRGB(71, 71, 71),
							Size = UDim2.fromOffset(40, 40),
						},
							create_element("UICorner",{
								CornerRadius = UDim.new(0, 5),
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
								Text = "Blud selected ts.. 💔",
							})
						),
--[[
single select (circle) checkbox
]]
						create_element("Frame",{
							BackgroundColor3 = Color3.fromRGB(54, 54, 54),
							Size = UDim2.fromOffset(40, 40),
						},
							create_element("UICorner",{
								CornerRadius = UDim.new(1, 0),
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
								Text = "Blud didnt select ts.. 💔",
							})
						),
--[[
active/selected single select (circle) checkbox
]]
						create_element("Frame",{
							BackgroundColor3 = Color3.fromRGB(71, 71, 71),
							Size = UDim2.fromOffset(40, 40),
						},
							create_element("UICorner",{
								CornerRadius = UDim.new(1, 0),
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
								Text = "Blud selected ts.. 💔",
							})
						),
--[[
switch toggled on
]]
						create_element("Frame",{ --track
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
								AnchorPoint = Vector2.new(1, 0.5), --set anchor point to 1 if toggled on
								BackgroundColor3 = Color3.fromRGB(54, 54, 54),
								Position = UDim2.fromScale(1, 0.5), --set position to 1 if toggled on
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
											ColorSequenceKeypoint.new(0, Color3.fromRGB(76, 177, 80)),
											ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 70, 70)),
										}),
									})
								)
							)
						),
--[[
switch toggled off
]]
						create_element("Frame",{ --track
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
								AnchorPoint = Vector2.new(0, 0.5), --set anchor point to 0 if toggled off
								BackgroundColor3 = Color3.fromRGB(54, 54, 54),
								Position = UDim2.fromScale(0, 0.5), --set position to 0 if toggled off
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
											ColorSequenceKeypoint.new(0, Color3.fromRGB(177, 76, 78)),
											ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 70, 70)),
										}),
									})
								)
							)
						),
--[[
dropdown menu
]]
						create_element("Frame",{
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
					)
				)
			)
		)
	)
end

return main
