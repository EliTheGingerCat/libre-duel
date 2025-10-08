local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.vendor.ReactLua.React)
local create_element = React.createElement

-- ===== Helpers =====
local function Corner(radius)
    return create_element("UICorner", {CornerRadius = UDim.new(0, radius)})
end

local function Stroke(color, thickness)
    return create_element("UIStroke", {Color = color, Thickness = thickness})
end

local function Gradient(from, to, rotation)
    return create_element("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, from),
            ColorSequenceKeypoint.new(1, to),
        }),
        Rotation = rotation or -90
    })
end

-- ===== Components =====
local function Panel(size, radius, children)
    return create_element("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(47, 47, 47),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = size,
    }, Corner(radius), Stroke(Color3.fromRGB(255, 255, 255), 2), Gradient(Color3.fromRGB(134,134,134), Color3.fromRGB(70,70,70)), table.unpack(children or {}))
end

local function Button(props)
    return create_element("TextButton", {
        AutomaticSize = props.AutomaticSize or "X",
        BackgroundColor3 = props.BackgroundColor3 or Color3.fromRGB(54,54,54),
        Size = props.Size or UDim2.fromOffset(200,50),
        FontFace = props.FontFace or Font.fromId(11702779409, Enum.FontWeight.Regular),
        TextColor3 = props.TextColor3 or Color3.fromRGB(198,198,198),
        Text = props.Text or "Button",
        TextSize = props.TextSize or 36,
    }, Corner(1), create_element("UIPadding",{PaddingLeft = UDim.new(0,10), PaddingRight = UDim.new(0,10)}), Stroke(Color3.fromRGB(255,255,255),2), Gradient(Color3.fromRGB(134,134,134), Color3.fromRGB(70,70,70)))
end

local function Slider(value, max, width)
    width = width or UDim2.new(1, -60, 0, 32)
    local track = create_element("Frame", {
        AnchorPoint = Vector2.new(0,0.5),
        Position = UDim2.new(0,10,0.5,0),
        BackgroundColor3 = Color3.fromRGB(54,54,54),
        Size = UDim2.new(1,0,0,10),
    }, Corner(1), Stroke(Color3.fromRGB(255,255,255),2), Gradient(Color3.fromRGB(134,134,134), Color3.fromRGB(70,70,70)))
    local thumb = create_element("Frame", {
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.fromScale(value/max,0.5),
        BackgroundColor3 = Color3.fromRGB(54,54,54),
        Size = UDim2.fromOffset(25,25)
    }, Corner(1), Stroke(Color3.fromRGB(255,255,255),2), Gradient(Color3.fromRGB(134,134,134), Color3.fromRGB(70,70,70)))
    
    return create_element("Frame",{BackgroundTransparency=1, Size=width}, track, thumb,
        create_element("TextLabel", {
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0,0.5),
            Position = UDim2.new(1,50,0.5,0),
            FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
            TextSize = 25,
            Text = tostring(value),
            TextColor3 = Color3.fromRGB(255,255,255)
        })
    )
end

local function Checkbox(labelText, active, shape)
    local bgColor = active and Color3.fromRGB(71,71,71) or Color3.fromRGB(54,54,54)
    local radius = shape=="circle" and 1 or 0
    return create_element("Frame", {
        BackgroundColor3 = bgColor,
        Size = UDim2.fromOffset(40,40)
    }, Corner(radius), Stroke(Color3.fromRGB(255,255,255),2), Gradient(Color3.fromRGB(134,134,134), Color3.fromRGB(70,70,70)),
        create_element("TextLabel", {
            AnchorPoint = Vector2.new(0,0.5),
            Position = UDim2.new(1,10,0.5,0),
            AutomaticSize = "X",
            FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
            TextColor3 = Color3.fromRGB(255,255,255),
            TextSize = 30,
            Text = labelText
        })
    )
end

local function Switch(on)
    local thumbAnchor = on and 1 or 0
    local thumbPos = UDim2.fromScale(thumbAnchor,0.5)
    local thumbColor = on and Color3.fromRGB(76,177,80) or Color3.fromRGB(177,76,78)
    return create_element("Frame",{BackgroundColor3=Color3.fromRGB(54,54,54), Size=UDim2.fromOffset(64,32)},
        Corner(1), Stroke(Color3.fromRGB(255,255,255),2), Gradient(Color3.fromRGB(134,134,134), Color3.fromRGB(70,70,70)),
        create_element("Frame",{AnchorPoint=Vector2.new(thumbAnchor,0.5), Position=thumbPos, BackgroundColor3=Color3.fromRGB(54,54,54), Size=UDim2.fromOffset(30,30)},
            Corner(1), Stroke(Color3.fromRGB(255,255,255),2), Gradient(thumbColor, Color3.fromRGB(70,70,70))
        )
    )
end

local function ColorPreview(color, label)
    return create_element("TextLabel", {
        BackgroundColor3 = color,
        Size = UDim2.new(1,0,0,128),
        FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
        RichText = true,
        TextColor3 = Color3.fromRGB(255,255,255),
        TextSize = 40,
        Text = label
    }, Corner(60), Stroke(Color3.fromRGB(255,255,255),2), Gradient(Color3.fromRGB(134,134,134), Color3.fromRGB(70,70,70)))
end

-- ===== Main GUI =====
local function main()
    return create_element("ScreenGui",{Enabled=true},
        Panel(UDim2.fromOffset(1366,768),65,{
            create_element("TextLabel",{ --title
                AnchorPoint = Vector2.new(0.5,0),
                BackgroundTransparency=1,
                Position=UDim2.fromScale(0.5,0),
                Size=UDim2.new(1,0,0,48),
                TextColor3=Color3.fromRGB(255,255,255),
                Text="Menu",
                FontFace=Font.fromId(11702779409,Enum.FontWeight.Bold),
                TextSize=30,
                ZIndex=2
            }),
            Button({Text="Button"}),
            Slider(100,100),
            Checkbox("Blud didnt select ts.. 💔", false, "square"),
            Checkbox("Blud selected ts.. 💔", true, "square"),
            Switch(true),
            ColorPreview(Color3.fromRGB(255,0,0), 'Really red\n<font size="20">rgb(255,0,0)\nhex(FF0000)</font>')
            -- Add additional elements as needed
        })
    )
end

return main
