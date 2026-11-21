const ReplicatedStorage = game:GetService("ReplicatedStorage")

const popup_types = require(ReplicatedStorage.shared.popup.popup_types)

export type on_popup_button_pressed = (
	player: Player,
	button_index: number,
	text_input_values: popup_types.popup_text_input_values
) -> ()

export type pending_popup = {
	player: Player,
	button_count: number,
	text_input_ids: { string },
	on_button_pressed: on_popup_button_pressed?,
}

-- popup id -> popup the client has not answered yet
const pending_popups: { [number]: pending_popup } = {}

return pending_popups
