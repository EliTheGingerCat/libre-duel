const ReplicatedStorage = game:GetService("ReplicatedStorage")

const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
const React = require(ReplicatedStorage.Packages.react)
const format_labelled_value = require(script.Parent.format_labelled_value)
const profile_types = require(script.Parent.profile_types)

const create_element = React.createElement
const STATS_PER_ROW = 4

const function stat_group(props: { group: profile_types.stat_group, layout_order: number? })
	const cells = {
		layout = create_element("UIGridLayout", {
			CellPadding = UDim2.new(),
			CellSize = UDim2.new(1 / STATS_PER_ROW, 0, 0, 52),
			FillDirectionMaxCells = STATS_PER_ROW,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	}
	for index, stat in props.group.stats do
		cells[stat.id] = create_element("TextLabel", {
			LayoutOrder = index,
			BackgroundTransparency = 1,
			FontFace = FONTS.regular,
			RichText = true,
			Text = format_labelled_value(`{stat.icon} {stat.label}`, stat.value),
			TextSize = 24,
			TextColor3 = Color3.new(1, 1, 1),
		})
	end
	return create_element("Frame", {
		Name = props.group.id,
		LayoutOrder = props.layout_order,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	}, {
		padding = create_element("UIPadding", {
			PaddingLeft = UDim.new(0, 16),
			PaddingRight = UDim.new(0, 16),
			PaddingBottom = UDim.new(0, 16),
		}),
		layout = create_element("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }),
		title = create_element("TextLabel", {
			LayoutOrder = 0,
			Size = UDim2.new(1, 0, 0, 48),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			FontFace = FONTS.semi_bold,
			Text = props.group.title,
			TextSize = 32,
			TextColor3 = Color3.new(1, 1, 1),
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
		stats = create_element("Frame", {
			LayoutOrder = 1,
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
		}, cells),
	})
end

return stat_group
