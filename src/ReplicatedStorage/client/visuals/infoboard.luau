local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local ReactRoblox = require(ReplicatedStorage.Packages["react-roblox"])

local create_element = React.createElement

local colours = require(ReplicatedStorage.modules.ui.colours)

type TextXAlignment = "Center" | "Left" | "Right"

type props_text_label = {
    layout_order: number,
    name: string,
    text: string,
    text_alignment_c1: TextXAlignment,
    text_size: number,
}
local function text_label(props: props_text_label)
    return create_element("TextLabel", {
        BackgroundTransparency = 1,
        FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
        LayoutOrder = props.layout_order,
        Name = props.name,
        RichText = true,
        TextSize = props.text_size,
        AutomaticSize = "XY",
        TextXAlignment = props.text_alignment_c1,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Text = props.text,
    })
end

type props_points_display = {
    colour: string,
    layout_order: number,
    name: string,
    points: number,
    text_alignment_c1: TextXAlignment,
}
local function point_display(props: props_points_display)
    local points_full = string.rep("●", props.points)
    local points_empty = string.rep("○", 5 - props.points)

    local text: string
    if props.text_alignment_c1 == "Left" then
        text = `<font color="{props.colour}">{points_full}</font>{points_empty}`
    elseif props.text_alignment_c1 == "Right" then
        text = `{points_empty}<font color="{props.colour}">{points_full}</font>`
    else
        print("Invalid text alignment.")
        return create_element("Frame")
    end

    return create_element(text_label, {
        layout_order = props.layout_order,
        name = props.name,
        text = text,
        text_alignment_c1 = props.text_alignment_c1,
        text_size = 50,
    })
end

local function infoboard()

    local kills = 41
    local map = "Astro"
    local points_blue = 1
    local points_self = 3
    local points_red = 3
    local time_elapsed = 1481

    local minutes = time_elapsed // 60
    local seconds = time_elapsed - minutes*60
    local time_string = string.format("%02d:%02d", minutes, seconds)

	return create_element("ScreenGui", {
		ClipToDeviceSafeArea = false,
		ScreenInsets = "None",
	},
        create_element("Frame", {
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.new(0.5, 0, 0, 10),
                Size = UDim2.fromOffset(401, 127),
                BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                BackgroundTransparency = 0.5,
        },
        	create_element("UIGridLayout", {
				CellSize = UDim2.fromOffset(175, 32),
                FillDirection = "Horizontal",
                SortOrder = "LayoutOrder",
                HorizontalAlignment = "Center",
                CellPadding = UDim2.fromScale(0, 0),
			}),
        	create_element("UIPadding", {
				PaddingBottom = UDim.new(0, 13),
                PaddingLeft = UDim.new(0, 15),
                PaddingRight = UDim.new(0, 15),
                PaddingTop = UDim.new(0, 15),
			}),
            create_element("UICorner", {
                CornerRadius = UDim.new(0.3, 0),
            }),
            create_element("UIStroke", {
                Thickness = 2,
				Color = Color3.fromRGB(255, 255, 255),
            },
            	create_element("UIGradient", {
                	Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(134, 134, 134)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 70, 70)),
                }),
					Rotation = -90,
            })),
            create_element(point_display, {
                colour = `#{colours.red:ToHex()}`,
                layout_order = 1,
                name = "points_red",
                points = points_red,
                text_alignment_c1 = "Left",
            }),
            create_element(point_display, {
                colour = `#{colours.blue:ToHex()}`,
                layout_order = 2,
                name = "points_blue",
                points = points_blue,
                text_alignment_c1 = "Right",
            }),
            create_element(text_label, {
                layout_order = 3,
                name = "map",
                text = `<font color="#{colours.green:ToHex()}">Map: </font>{map}`,
                text_alignment_c1 = "Left",
                text_size = 30,
            }),
            create_element(text_label, {
                layout_order = 4,
                name = "timer",
                text = `<font color="#{colours.green:ToHex()}">Time: </font>{time_string}`,
                text_alignment_c1 = "Right",
                text_size = 30,
            }),
            create_element(text_label, {
                layout_order = 5,
                name = "kills",
                text = `<font color="#{colours.green:ToHex()}">Kills: </font>{kills}`,
                text_alignment_c1 = "Left",
                text_size = 30,
            }),
            create_element(text_label, {
                layout_order = 6,
                name = "points_self",
                text = `<font color="#{colours.green:ToHex()}">Goals: </font>{points_self}`,
                text_alignment_c1 = "Right",
                text_size = 30,
            })
        )
    )
end

return infoboard
