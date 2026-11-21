const ReplicatedStorage = game:GetService("ReplicatedStorage")

const React = require(ReplicatedStorage.Packages.react)
const profile_types = require(script.Parent.profile_types)
const stat_group = require(script.Parent.stat_group)

const create_element = React.createElement

const function stat_groups(props: { groups: { profile_types.stat_group }, layout_order: number? })
	const children = {
		layout = create_element("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }),
	}
	for index, group in props.groups do
		children[group.id] = create_element(stat_group, { group = group, layout_order = index })
	end
	return create_element("Frame", {
		Name = "stats",
		LayoutOrder = props.layout_order,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	}, children)
end

return stat_groups
