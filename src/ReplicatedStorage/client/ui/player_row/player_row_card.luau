const ReplicatedStorage = game:GetService("ReplicatedStorage")

const PLAYER_ROW_LAYOUT = require(script.Parent.PLAYER_ROW_LAYOUT)
const React = require(ReplicatedStorage.Packages.react)

const create_element = React.createElement

-- rounded background that clips a player_banner_row and anything stacked under it, like expandable stats
const function player_row_card(props: { name: string?, layout_order: number?, children: unknown? })
	return create_element("CanvasGroup", {
		Name = props.name,
		LayoutOrder = props.layout_order,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = PLAYER_ROW_LAYOUT.background,
	}, {
		corner = create_element("UICorner", { CornerRadius = UDim.new(0, PLAYER_ROW_LAYOUT.corner_radius) }),
		layout = create_element("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }),
		content = create_element(React.Fragment, nil, props.children),
	})
end

return player_row_card
