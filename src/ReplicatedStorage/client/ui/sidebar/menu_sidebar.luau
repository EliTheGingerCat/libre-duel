const ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const React = require(ReplicatedStorage.Packages.react)
const shadow = require(script.Parent.Parent.components.decoration.shadow)
const sidebar_button = require(script.Parent.sidebar_button)
const sidebar_types = require(script.Parent.sidebar_types)

const create_element = React.createElement
const BUTTON_HEIGHT = 50
const BUTTON_GAP = 5
const EDGE_PADDING = 20

export type props = {
	entries: { sidebar_types.entry },
	selected: string,
	on_selected: (string) -> (),
	-- something pinned above the entries, like a search bar
	header: unknown?,
	header_height: number?,
}

const function create_slot(entry: sidebar_types.entry, index: number, selected: string, on_selected: (string) -> ())
	return create_element("Frame", {
		LayoutOrder = index,
		Size = UDim2.new(1, 0, 0, BUTTON_HEIGHT),
		BackgroundTransparency = 1,
	}, {
		button = create_element(
			sidebar_button,
			{ entry = entry, selected = selected == entry.id, on_selected = on_selected }
		),
	})
end

const function menu_sidebar(props: props)
	const header_height = props.header_height or 0
	const buttons = {
		padding = create_element("UIPadding", {
			PaddingLeft = UDim.new(0, EDGE_PADDING),
			PaddingRight = UDim.new(0, EDGE_PADDING),
			PaddingTop = UDim.new(0, EDGE_PADDING),
			PaddingBottom = UDim.new(0, EDGE_PADDING),
		}),
		layout = create_element(
			"UIListLayout",
			{ Padding = UDim.new(0, BUTTON_GAP), SortOrder = Enum.SortOrder.LayoutOrder }
		),
	}
	const bottom = {
		layout = create_element("UIListLayout", {
			Padding = UDim.new(0, BUTTON_GAP),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
		}),
	}
	local bottom_count = 0
	for index, entry in props.entries do
		if entry.bottom then
			bottom_count += 1
			bottom[entry.id] = create_slot(entry, index, props.selected, props.on_selected)
		else
			buttons[entry.id] = create_slot(entry, index, props.selected, props.on_selected)
		end
	end
	const bottom_height = if bottom_count > 0
		then bottom_count * BUTTON_HEIGHT + (bottom_count - 1) * BUTTON_GAP + EDGE_PADDING
		else 0
	return create_element("Frame", {
		Name = "sidebar",
		Position = UDim2.fromOffset(20, 20),
		Size = UDim2.new(0.25, -20, 1, -40),
		BackgroundColor3 = COLOURS.surface,
		BackgroundTransparency = 0.5,
	}, {
		corner = create_element("UICorner", { CornerRadius = UDim.new(0, 40) }),
		shadow = create_element(shadow, { BlurRadius = UDim.new(0, 8), Transparency = 0.3, ShowBehindParent = false }),
		header = props.header and create_element("Frame", {
			Position = UDim2.fromOffset(EDGE_PADDING, EDGE_PADDING),
			Size = UDim2.new(1, -EDGE_PADDING * 2, 0, header_height),
			BackgroundTransparency = 1,
		}, props.header),
		categories = create_element("ScrollingFrame", {
			Position = UDim2.fromOffset(0, if props.header then header_height + EDGE_PADDING else 0),
			Size = UDim2.new(1, 0, 1, -(if props.header then header_height + EDGE_PADDING else 0) - bottom_height),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 0,
			CanvasSize = UDim2.fromOffset(0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
		}, buttons),
		bottom = bottom_count > 0 and create_element("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, EDGE_PADDING, 1, -EDGE_PADDING),
			Size = UDim2.new(1, -EDGE_PADDING * 2, 0, bottom_height - EDGE_PADDING),
			BackgroundTransparency = 1,
		}, bottom),
	})
end

return menu_sidebar
