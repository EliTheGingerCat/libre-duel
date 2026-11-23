const ReplicatedStorage = game:GetService("ReplicatedStorage")

const React = require(ReplicatedStorage.Packages.react)
const info_field_label = require(script.Parent.info_field_label)
const profile_types = require(script.Parent.profile_types)

const create_element = React.createElement

-- meant to sit inside a section_card, three fields per line
const function info_fields(props: { fields: { profile_types.info_field } })
	const labels = {}
	for index, field in props.fields do
		labels[field.id] = create_element(info_field_label, { field = field, layout_order = index })
	end
	return create_element(React.Fragment, nil, labels)
end

return info_fields
