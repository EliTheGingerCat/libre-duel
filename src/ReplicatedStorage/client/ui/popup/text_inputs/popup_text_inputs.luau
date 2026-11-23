const ReplicatedStorage = game:GetService("ReplicatedStorage")

const POPUP_LAYOUT = require(script.Parent.Parent.POPUP_LAYOUT)
const React = require(ReplicatedStorage.Packages.react)
const popup_types = require(ReplicatedStorage.shared.popup.popup_types)
const text_input = require(script.Parent.Parent.Parent.components.inputs.text_input)

const create_element = React.createElement

const function popup_text_inputs(props: {
	text_inputs: { popup_types.popup_text_input },
	layout_order: number,
	on_text_changed: (id: string, text: string) -> (),
})
	const text_input_elements = {}
	for text_input_index, popup_text_input in props.text_inputs do
		const function on_changed(text: string): ()
			props.on_text_changed(popup_text_input.id, text)
		end

		text_input_elements[`text_input_{popup_text_input.id}`] = create_element(text_input, {
			placeholder = popup_text_input.placeholder_text,
			radius = POPUP_LAYOUT.ROW_CORNER_RADIUS,
			layout_order = text_input_index,
			on_changed = on_changed,
		})
	end

	return create_element("Frame", {
		Name = "text_inputs",
		LayoutOrder = props.layout_order,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	}, {
		layout = create_element("UIListLayout", {
			Padding = UDim.new(0, POPUP_LAYOUT.ROW_GAP),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		text_inputs = create_element(React.Fragment, {}, text_input_elements),
	})
end

return popup_text_inputs
