local ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
local React = require(ReplicatedStorage.Packages.react)
local animated_button = require(script.Parent.Parent.Parent.components.buttons.animated_button)
local button_motion = require(script.Parent.Parent.Parent.components.buttons.button_motion)
local gradient_stroke = require(script.Parent.Parent.Parent.components.decoration.gradient_stroke)
local hud_registry = require(script.Parent.Parent.registry.hud_registry)
local shadow = require(script.Parent.Parent.Parent.components.decoration.shadow)

local create_element = React.createElement

const function hud_widget_selector_tile(props: {
	item: hud_registry.entry,
	title: string,
	order: number,
	on_close: () -> (),
})
	const function select_widget(): ()
		props.on_close()
		hud_registry.add(props.item)
	end
	return create_element(animated_button, {
		Name = props.item.screen.Name,
		LayoutOrder = props.order,
		Size = UDim2.fromOffset(256, 256),
		BackgroundColor3 = COLOURS.surface,
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Text = props.title,
		TextSize = 36,
		TextColor3 = Color3.new(1, 1, 1),
		TextYAlignment = Enum.TextYAlignment.Bottom,
		FontFace = FONTS.regular,
		[React.Event.Activated] = select_widget,
	}, {
		feedback = create_element(button_motion),
		shadow = create_element(shadow, { ShowBehindParent = false, BlurRadius = UDim.new(0, 8), Transparency = 0.3 }),
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

return hud_widget_selector_tile
