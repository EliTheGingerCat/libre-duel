export type popup_text_input = {
	id: string,
	placeholder_text: string,
}

export type popup_button = {
	text: string,
	colour: Color3,
	-- seconds the button has to be held to press it, nil presses it on click
	button_progress_time: number?,
}

export type popup_params = {
	icon: string,
	text: string,
	text_inputs: { popup_text_input }?,
	buttons: { popup_button }?,
}

-- text input id -> what the player typed
export type popup_text_input_values = { [string]: string }

return {}
