const ReplicatedStorage = game:GetService("ReplicatedStorage")

const PLAYER_ROW_LAYOUT = require(script.Parent.Parent.Parent.player_row.PLAYER_ROW_LAYOUT)
const React = require(ReplicatedStorage.Packages.react)
const member_columns = require(script.Parent.member_columns)

const create_element = React.createElement
const SEPARATOR_COLOUR = Color3.fromRGB(200, 200, 200)

-- date_label names the last column, "Joined" for members and "Banned" for the ban list
const function member_header_row(props: { layout_order: number?, date_label: string? })
	const headshot_size = PLAYER_ROW_LAYOUT.height - PLAYER_ROW_LAYOUT.padding * 2
	return create_element("Frame", {
		Name = "header_row",
		LayoutOrder = props.layout_order,
		Size = UDim2.new(1, 0, 0, 48),
		BackgroundTransparency = 1,
	}, {
		row = create_element("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
		}, {
			padding = create_element("UIPadding", {
				PaddingLeft = UDim.new(0, PLAYER_ROW_LAYOUT.padding),
				-- matches the space banner rows keep for their action button
				PaddingRight = UDim.new(
					0,
					PLAYER_ROW_LAYOUT.padding + PLAYER_ROW_LAYOUT.action_size + PLAYER_ROW_LAYOUT.action_inset
				),
			}),
			layout = create_element("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, PLAYER_ROW_LAYOUT.headshot_gap),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			headshot_space = create_element("Frame", {
				LayoutOrder = 1,
				Size = UDim2.new(0, headshot_size, 1, 0),
				BackgroundTransparency = 1,
			}),
			columns = create_element(member_columns, {
				layout_order = 2,
				display_name = "Display name",
				username = "Username",
				joined = props.date_label or "Joined",
			}),
		}),
		separator = create_element("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = SEPARATOR_COLOUR,
			BorderSizePixel = 0,
		}),
	})
end

return member_header_row
