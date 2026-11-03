local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local MODE_OPTIONS = require(script.Parent.MODE_OPTIONS)
local animated_button = require(script.Parent.Parent.visuals.animated_button)
local button_motion = require(script.Parent.Parent.visuals.button_motion)
local gradient_stroke = require(script.Parent.Parent.visuals.gradient_stroke)

local create_element = React.createElement

local function mode_option(props: { mode: MODE_OPTIONS.mode, busy: boolean, on_activate: () -> () })
	local option = MODE_OPTIONS[props.mode]
	return create_element(animated_button, {
		Name = `{props.mode}_button`,
		LayoutOrder = if props.mode == "solo" then 1 else 2,
		Size = UDim2.new(1, 0, 0, 192),
		BackgroundColor3 = Color3.fromRGB(17, 17, 17),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Text = `{option.name}\n<font color="rgb(180,180,180)"><font size="28">{option.description}</font></font>`,
		RichText = true,
		TextSize = 56,
		TextColor3 = Color3.new(1, 1, 1),
		FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
		Interactable = not props.busy,
		[React.Event.Activated] = props.on_activate,
	}, {
		feedback = create_element(button_motion),
		shadow = create_element(
			"UIShadow",
			{ ShowBehindParent = false, BlurRadius = UDim.new(0, 8), Transparency = 0.3 }
		),
		corner = create_element("UICorner", { CornerRadius = UDim.new(0, 60) }),
		stroke = create_element(gradient_stroke, { colour = option.colour }),
		icon = create_element(
			"ImageLabel",
			{
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 48, 0.5, 0),
				Size = UDim2.fromOffset(100, 100),
				BackgroundTransparency = 1,
				Image = option.icon,
			},
			create_element("UIGradient", {
				Color = ColorSequence.new(option.colour, Color3.new(70 / 255, 70 / 255, 70 / 255)),
				Rotation = -90,
			})
		),
	})
end

return mode_option
