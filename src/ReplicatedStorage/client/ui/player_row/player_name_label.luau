const ReplicatedStorage = game:GetService("ReplicatedStorage")

const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
const React = require(ReplicatedStorage.Packages.react)

const create_element = React.createElement

const function create_name_part(text: string, font: Font, layout_order: number, shrinks: boolean)
	return create_element("TextLabel", {
		LayoutOrder = layout_order,
		Size = UDim2.fromScale(0, 1),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		FontFace = font,
		Text = text,
		TextSize = 24,
		TextColor3 = Color3.new(1, 1, 1),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, {
		flex = shrinks and create_element("UIFlexItem", { FlexMode = Enum.UIFlexMode.Shrink }),
	})
end

-- "display name (@username)" on one line, the display name shrinks first so the username always stays readable
const function player_name_label(props: { display_name: string, username: string, layout_order: number? })
	return create_element("Frame", {
		Name = "name",
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
		display_name = create_name_part(props.display_name, FONTS.semi_bold, 1, true),
		username = create_name_part(` (@{props.username})`, FONTS.regular, 2, false),
	})
end

return player_name_label
