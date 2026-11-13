const ReplicatedStorage = game:GetService("ReplicatedStorage")

const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
const React = require(ReplicatedStorage.Packages.react)
const controller_glyph_types = require(script.Parent.controller_glyph_types)
const gamepad_glyph = require(script.Parent.Parent.Parent.glyphs.gamepad_glyph)

const create_element = React.createElement

const GLYPH_SIZE = 30
const ROW_HEIGHT = 32

type props = {
	row: controller_glyph_types.controller_glyph_row,
	layout_order: number,
}

-- glyphs sit on the right so they line up against the screen edge, with the label to their left
const function controller_glyph_row(props: props)
	const glyphs = {}
	for glyph_index, key_code in props.row.key_codes do
		glyphs[key_code.Name] =
			create_element(gamepad_glyph, { key_code = key_code, size = GLYPH_SIZE, layout_order = glyph_index })
	end

	return create_element("Frame", {
		LayoutOrder = props.layout_order,
		Size = UDim2.new(1, 0, 0, ROW_HEIGHT),
		BackgroundTransparency = 1,
	}, {
		layout = create_element("UIListLayout", {
			Padding = UDim.new(0, 10),
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		label = create_element("TextLabel", {
			LayoutOrder = 0,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 1, 0),
			BackgroundTransparency = 1,
			Text = props.row.label,
			TextSize = 24,
			TextColor3 = Color3.new(1, 1, 1),
			FontFace = FONTS.regular,
		}),
		glyphs = create_element("Frame", {
			LayoutOrder = 1,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 1, 0),
			BackgroundTransparency = 1,
		}, {
			layout = create_element("UIListLayout", {
				Padding = UDim.new(0, 4),
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			glyphs = create_element(React.Fragment, nil, glyphs),
		}),
	})
end

return controller_glyph_row
