const ReplicatedStorage = game:GetService("ReplicatedStorage")

const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
const React = require(ReplicatedStorage.Packages.react)
const profile_types = require(script.Parent.profile_types)

const create_element = React.createElement
const DEFAULT_VALUE_COLOUR = Color3.fromRGB(200, 200, 200)

const function create_highlight(stat: profile_types.highlight_stat, layout_order: number)
	return create_element("Frame", {
		Name = stat.id,
		LayoutOrder = layout_order,
		Size = UDim2.fromScale(0.33, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	}, {
		layout = create_element("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }),
		label = create_element("TextLabel", {
			LayoutOrder = 1,
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			FontFace = FONTS.regular,
			Text = if stat.icon then `{stat.icon} {stat.label}` else stat.label,
			TextSize = 24,
			TextColor3 = Color3.new(1, 1, 1),
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
		value = create_element("TextLabel", {
			LayoutOrder = 2,
			Size = UDim2.fromScale(1, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			FontFace = FONTS.regular,
			Text = stat.value,
			TextSize = 40,
			TextColor3 = stat.colour or DEFAULT_VALUE_COLOUR,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
		}),
	})
end

-- meant to sit inside a section_card, three stats per line
const function highlight_stats(props: { stats: { profile_types.highlight_stat } })
	const highlights = {}
	for index, stat in props.stats do
		highlights[stat.id] = create_highlight(stat, index)
	end
	return create_element(React.Fragment, nil, highlights)
end

return highlight_stats
