const ReplicatedStorage = game:GetService("ReplicatedStorage")

const FONTS = require(ReplicatedStorage.shared.ui.FONTS)
const React = require(ReplicatedStorage.Packages.react)
const format_labelled_value = require(script.Parent.format_labelled_value)
const profile_types = require(script.Parent.profile_types)

const create_element = React.createElement

-- meant to sit inside a section_card, three fields per line
const function info_fields(props: { fields: { profile_types.info_field } })
	const labels = {}
	for index, field in props.fields do
		labels[field.id] = create_element("TextLabel", {
			LayoutOrder = index,
			Size = UDim2.fromScale(0.33, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			FontFace = FONTS.regular,
			RichText = true,
			Text = format_labelled_value(field.label, field.value),
			TextSize = 24,
			TextColor3 = Color3.new(1, 1, 1),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
		})
	end
	return create_element(React.Fragment, nil, labels)
end

return info_fields
