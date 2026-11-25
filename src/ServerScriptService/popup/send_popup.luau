const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const pending_popups = require(script.Parent.pending_popups)
const popup_types = require(ReplicatedStorage.shared.popup.popup_types)
const zap_server_network = require(ServerScriptService.network.zap_server_network)

local current_id = 0

const function get_text_input_ids(params: popup_types.popup_params): { string }
	const text_input_ids = {}
	const seen_ids: { [string]: true } = {}
	const text_inputs = params.text_inputs
	if text_inputs == nil then
		return text_input_ids
	end
	for _, text_input in text_inputs do
		assert(not seen_ids[text_input.id], `duplicate popup text input id "{text_input.id}"`)
		seen_ids[text_input.id] = true
		table.insert(text_input_ids, text_input.id)
	end
	return text_input_ids
end

-- on_button_pressed gets the index of the pressed button in params.buttons and what was typed in each text input by id
const function send_popup(
	player: Player,
	params: popup_types.popup_params,
	on_button_pressed: pending_popups.on_popup_button_pressed?
): ()
	current_id += 1

	pending_popups[current_id] = {
		player = player,
		button_count = if params.buttons then #params.buttons else 0,
		text_input_ids = get_text_input_ids(params),
		on_button_pressed = on_button_pressed,
	}
	zap_server_network.send_popup.fire(player, current_id, params)
end

return send_popup
