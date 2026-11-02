local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.react)
local animated_button = require(script.Parent.Parent.visuals.animated_button)
local button_motion = require(script.Parent.Parent.visuals.button_motion)
local gradient_stroke = require(script.Parent.Parent.visuals.gradient_stroke)
local registry = require(script.Parent.registry)

local create_element = React.createElement

local function selector_tile(props: { item: registry.entry, title: string, order: number, on_close: () -> () })
	local function select_widget(): ()
		props.on_close()
		registry.add(props.item)
	end
	return create_element(animated_button, {
		Name = props.item.screen.Name,
		LayoutOrder = props.order,
		Size = UDim2.fromOffset(256, 256),
		BackgroundColor3 = Color3.fromRGB(17, 17, 17),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Text = props.title,
		TextSize = 36,
		TextColor3 = Color3.new(1, 1, 1),
		TextYAlignment = Enum.TextYAlignment.Bottom,
		FontFace = Font.fromId(11702779409, Enum.FontWeight.Regular),
		[React.Event.Activated] = select_widget,
	}, {
		feedback = create_element(button_motion),
		shadow = create_element(
			"UIShadow",
			{ ShowBehindParent = false, BlurRadius = UDim.new(0, 8), Transparency = 0.3 }
		),
		corner = create_element("UICorner", { CornerRadius = UDim.new(0, 60) }),
		stroke = create_element(gradient_stroke),
		padding = create_element("UIPadding", { PaddingBottom = UDim.new(0, 16) }),
		preview = create_element("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 0.8),
			Active = false,
		}, if props.item.render_preview then props.item.render_preview() else nil),
	})
end

return selector_tile
