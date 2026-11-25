const ReplicatedStorage = game:GetService("ReplicatedStorage")

const POPUP_TEXT_INPUT_MAX_LENGTH = require(ReplicatedStorage.shared.popup.POPUP_TEXT_INPUT_MAX_LENGTH)
const popup_management = require(script.Parent.popup_management)
const popup_types = require(ReplicatedStorage.shared.popup.popup_types)
const zap_client_network = require(ReplicatedStorage.client.network.zap_client_network)

-- zap refuses to send text over the limit, the server would cut it to the same length anyway
const function cut_to_max_length(text: string): string
	const cut_offset = utf8.offset(text, POPUP_TEXT_INPUT_MAX_LENGTH + 1)
	if cut_offset == nil then
		return text
	end
	return string.sub(text, 1, cut_offset - 1)
end

const function on_popup_received(server_id: number, params: popup_types.popup_params): ()
	const function send_response_to_server(
		button_index: number?,
		text_input_values: popup_types.popup_text_input_values
	): ()
		const cut_values = {}
		for text_input_id, text in text_input_values do
			cut_values[text_input_id] = cut_to_max_length(text)
		end
		zap_client_network.respond_to_popup.fire(server_id, button_index, cut_values)
	end

	popup_management.add(params, send_response_to_server)
end

zap_client_network.send_popup.set_callback(on_popup_received)
