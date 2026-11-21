const ReplicatedStorage = game:GetService("ReplicatedStorage")

const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
const PLAYER_ROW_LAYOUT = require(script.Parent.Parent.Parent.player_row.PLAYER_ROW_LAYOUT)
const React = require(ReplicatedStorage.Packages.react)
const escape_rich_text = require(ReplicatedStorage.shared.ui.escape_rich_text)

const create_element = React.createElement

const function create_column(text: string, layout_order: number)
	return create_element("TextLabel", {
		LayoutOrder = layout_order,
		Size = UDim2.fromScale(PLAYER_ROW_LAYOUT.column_width, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		FontFace = FONTS.regular,
		RichText = true,
		Text = text,
		TextSize = 24,
		TextColor3 = Color3.new(1, 1, 1),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	})
end

-- the display name, username and joined columns, takes plain text and escapes it
const function member_columns(props: { display_name: string, username: string, joined: string, layout_order: number? })
	return create_element("Frame", {
		Name = "columns",
		LayoutOrder = props.layout_order,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, {
		flex = create_element("UIFlexItem", { FlexMode = Enum.UIFlexMode.Fill }),
		layout = create_element("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		display_name = create_column(escape_rich_text(props.display_name), 1),
		username = create_column(escape_rich_text(props.username), 2),
		joined = create_column(escape_rich_text(props.joined), 3),
	})
end

return member_columns
