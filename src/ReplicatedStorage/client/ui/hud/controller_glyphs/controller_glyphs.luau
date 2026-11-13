const ReplicatedStorage = game:GetService("ReplicatedStorage")

const HUD_DEFAULTS = require(script.Parent.Parent.HUD_DEFAULTS)
const React = require(ReplicatedStorage.Packages.react)
const controller_glyph_row = require(script.Parent.controller_glyph_row)
const hud_screen = require(script.Parent.Parent.hud_screen)
const use_controller_glyph_rows = require(script.Parent.use_controller_glyph_rows)
const use_editable_hud = require(script.Parent.Parent.use_editable_hud)

const create_element = React.createElement

const WIDGET_NAME = "ControllerGlyphs"

-- local instead of const since it passes itself to use_editable_hud for its copies
local function controller_glyphs(props: use_editable_hud.props)
	const defaults = HUD_DEFAULTS[WIDGET_NAME]
	assert(defaults)
	const content_ref = use_editable_hud(controller_glyphs, props, defaults.hidden)
	const rows = use_controller_glyph_rows(props.preview)

	const row_elements = {}
	for row_index, row in rows do
		row_elements[row.label] = create_element(controller_glyph_row, { row = row, layout_order = row_index })
	end

	return create_element(
		hud_screen,
		{ Name = WIDGET_NAME, ResetOnSpawn = false, preview = props.preview },
		create_element("Frame", {
			ref = content_ref,
			Name = "content",
			Size = UDim2.fromOffset(defaults.size.X, defaults.size.Y),
			BackgroundTransparency = 1,
			AnchorPoint = if props.preview then Vector2.new(0.5, 0.5) else defaults.anchor,
			Position = if props.preview then UDim2.fromOffset(0, 0) else defaults.position,
		}, {
			-- rows come and go, so they stack up from the bottom to keep the screen corner as the anchor
			layout = create_element("UIListLayout", {
				Padding = UDim.new(0, 6),
				FillDirection = Enum.FillDirection.Vertical,
				VerticalAlignment = Enum.VerticalAlignment.Bottom,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			rows = create_element(React.Fragment, nil, row_elements),
		})
	)
end

return controller_glyphs
