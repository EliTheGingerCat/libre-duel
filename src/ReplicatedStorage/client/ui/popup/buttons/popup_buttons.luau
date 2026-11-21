const ReplicatedStorage = game:GetService("ReplicatedStorage")

const POPUP_LAYOUT = require(script.Parent.Parent.POPUP_LAYOUT)
const React = require(ReplicatedStorage.Packages.react)
const popup_button = require(script.Parent.popup_button)
const popup_types = require(ReplicatedStorage.shared.popup.popup_types)

const create_element = React.createElement

const function popup_buttons(props: {
	buttons: { popup_types.popup_button },
	layout_order: number,
	on_button_pressed: (button_index: number) -> (),
})
	const button_elements = {}
	for button_index, button in props.buttons do
		const function on_pressed(): ()
			props.on_button_pressed(button_index)
		end

		button_elements[`button_{button_index}`] = create_element(popup_button, {
			button = button,
			layout_order = button_index,
			on_pressed = on_pressed,
		})
	end

	return create_element("Frame", {
		Name = "buttons",
		LayoutOrder = props.layout_order,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	}, {
		layout = create_element("UIListLayout", {
			Padding = UDim.new(0, POPUP_LAYOUT.ROW_GAP),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		buttons = create_element(React.Fragment, {}, button_elements),
	})
end

return popup_buttons
