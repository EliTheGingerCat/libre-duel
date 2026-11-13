local ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const INVENTORY_LAYOUT = require(script.Parent.INVENTORY_LAYOUT)
local React = require(ReplicatedStorage.Packages.react)
local gradient_stroke = require(script.Parent.Parent.visuals.gradient_stroke)
local shadow = require(script.Parent.Parent.visuals.shadow)

local create_element = React.createElement

const function get_length(cells: number): number
	return cells * INVENTORY_LAYOUT.SLOT_SIZE
		+ (cells - 1) * INVENTORY_LAYOUT.SLOT_GAP
		+ INVENTORY_LAYOUT.BOX_PADDING * 2
end

-- The rounded box around a grid of `count` slots, `columns` per row.
-- Its size is fixed, since a grid inside an automatically sized frame wraps at whatever width it guesses.
const function slot_box(props: {
	name: string,
	columns: number,
	count: number,
	layout_order: number?,
	position: unknown?,
	children: unknown?,
})
	return create_element("Frame", {
		BackgroundColor3 = COLOURS.surface,
		BackgroundTransparency = 0.5,
		LayoutOrder = props.layout_order,
		Name = props.name,
		Position = props.position,
		Size = UDim2.fromOffset(get_length(props.columns), get_length(math.ceil(props.count / props.columns))),
	}, {
		corner = create_element("UICorner", { CornerRadius = UDim.new(0, INVENTORY_LAYOUT.BOX_RADIUS) }),
		grid = create_element("UIGridLayout", {
			CellPadding = UDim2.fromOffset(INVENTORY_LAYOUT.SLOT_GAP, INVENTORY_LAYOUT.SLOT_GAP),
			CellSize = UDim2.fromOffset(INVENTORY_LAYOUT.SLOT_SIZE, INVENTORY_LAYOUT.SLOT_SIZE),
			FillDirectionMaxCells = props.columns,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		padding = create_element("UIPadding", {
			PaddingBottom = UDim.new(0, INVENTORY_LAYOUT.BOX_PADDING),
			PaddingLeft = UDim.new(0, INVENTORY_LAYOUT.BOX_PADDING),
			PaddingRight = UDim.new(0, INVENTORY_LAYOUT.BOX_PADDING),
			PaddingTop = UDim.new(0, INVENTORY_LAYOUT.BOX_PADDING),
		}),
		shadow = create_element(shadow, { ShowBehindParent = false, BlurRadius = UDim.new(0, 8), Transparency = 0.3 }),
		stroke = create_element(gradient_stroke),
		slots = create_element(React.Fragment, {}, props.children),
	})
end

return slot_box
