local ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
const INVENTORY_LAYOUT = require(script.Parent.INVENTORY_LAYOUT)
local React = require(ReplicatedStorage.Packages.react)
local gradient_stroke = require(script.Parent.Parent.visuals.gradient_stroke)

local create_element = React.createElement

const CORNER_RADIUS = UDim.new(0.45, 0)
const COLOUR = Color3.new(18 / 255, 18 / 255, 18 / 255)
const COLOUR_SELECTED = Color3.fromRGB(100, 100, 100)

-- A single slot. `image` is nil for an empty slot, `selected` highlights it (such as the active hotbar slot).
-- `amount` shows as a counter when there's more than one.
-- With `on_click` the slot is a button, which also stops the click from reaching the game.
local function item_slot(props: {
	name: string,
	image: string?,
	amount: number?,
	layout_order: number,
	selected: boolean?,
	on_click: (() -> ())?,
})
	const clickable = props.on_click ~= nil
	return create_element(if clickable then "TextButton" else "Frame", {
		[React.Event.Activated] = props.on_click,
		AutoButtonColor = if clickable then false else nil,
		Text = if clickable then "" else nil,
		BackgroundColor3 = if props.selected then COLOUR_SELECTED else COLOUR,
		BackgroundTransparency = 0.8,
		LayoutOrder = props.layout_order,
		Name = props.name,
		Size = UDim2.fromOffset(INVENTORY_LAYOUT.SLOT_SIZE, INVENTORY_LAYOUT.SLOT_SIZE),
	}, {
		aspect = create_element("UIAspectRatioConstraint"),
		corner = create_element("UICorner", { CornerRadius = CORNER_RADIUS }),
		icon = props.image ~= nil and create_element("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = props.image,
			Name = "icon",
			Position = UDim2.fromScale(0.5, 0.5),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(INVENTORY_LAYOUT.ICON_SCALE, INVENTORY_LAYOUT.ICON_SCALE),
		}),
		amount = props.amount ~= nil and props.amount > 1 and create_element("TextLabel", {
			AnchorPoint = Vector2.new(1, 1),
			BackgroundTransparency = 1,
			FontFace = FONTS.semi_bold,
			Name = "amount",
			Position = UDim2.fromScale(0.95, 1),
			Size = UDim2.fromScale(0.6, 0.4),
			Text = tostring(props.amount),
			TextColor3 = COLOURS.white,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Right,
			ZIndex = 2,
		}),
		stroke = props.selected and create_element(gradient_stroke),
	})
end

return item_slot
