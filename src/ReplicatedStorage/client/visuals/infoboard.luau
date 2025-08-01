local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.vendor.ReactLua.React)
local create_element = React.createElement

local function main()
	return create_element("ScreenGui",{
		ClipToDeviceSafeArea = false,
		ScreenInsets = "None",
	},
        create_element("Frame",{
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.new(0.5, 0, 0, 10),
                Size = UDim2.fromOffset(401, 127),
                BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                BackgroundTransparency = 0.5,
        },
        	create_element("UIGridLayout",{
				CellSize = UDim2.fromOffset(175, 32),
                FillDirection = "Horizontal",
                SortOrder = "LayoutOrder",
                HorizontalAlignment = "Center",
                CellPadding = UDim2.fromScale(0, 0),
			}),
        	create_element("UIPadding",{
				PaddingBottom = UDim.new(0, 13),
                PaddingLeft = UDim.new(0, 15),
                PaddingRight = UDim.new(0, 15),
                PaddingTop = UDim.new(0, 15),
			}),
            create_element("UICorner",{
                CornerRadius = UDim.new(0.3, 0),
            }),
            create_element("UIStroke",{
                Thickness = 2,
				Color = Color3.fromRGB(255, 255, 255),
            },
            	create_element("UIGradient",{
                	Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(134, 134, 134)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 70, 70)),
                }),
					Rotation = -90,
            })),
            create_element("TextLabel",{ -- red goals
                BackgroundTransparency = 1,
                FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
                LayoutOrder = 1,
                RichText = true,
                TextSize = 50,
                AutomaticSize = "XY",
                TextXAlignment = "Left",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Text = '<font color="#b14c4e">●●●</font>○○',
            }),
            create_element("TextLabel",{ -- blue goals
                BackgroundTransparency = 1,
                FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
                LayoutOrder = 2,
                RichText = true,
                TextSize = 50,
                AutomaticSize = "XY",
                TextXAlignment = "Right",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Text = '○○○○<font color="#0da2dd">●</font>',
            }),
            create_element("TextLabel",{ -- map
                BackgroundTransparency = 1,
                FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
                LayoutOrder = 3,
                RichText = true,
                TextSize = 30,
                AutomaticSize = "XY",
                TextXAlignment = "Left",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Text = '<font color="#5bd34c">Map: </font>Astro',
            }),
            create_element("TextLabel",{ -- timer
                BackgroundTransparency = 1,
                FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
                LayoutOrder = 4,
                RichText = true,
                TextSize = 30,
                AutomaticSize = "XY",
                TextXAlignment = "Right",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Text = '<font color="#5bd34c">Time: </font>24:41',
            }),
            create_element("TextLabel",{ -- kill counter
                BackgroundTransparency = 1,
                FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
                LayoutOrder = 5,
                RichText = true,
                TextSize = 30,
                AutomaticSize = "XY",
                TextXAlignment = "Left",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Text = '<font color="#5bd34c">Kills: </font>41',
            }),
            create_element("TextLabel",{ -- goal counter
                BackgroundTransparency = 1,
                FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
                LayoutOrder = 6,
                RichText = true,
                TextSize = 30,
                AutomaticSize = "XY",
                TextXAlignment = "Right",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Text = '<font color="#5bd34c">Goals: </font>3',
            })
        )
    )
end

return main