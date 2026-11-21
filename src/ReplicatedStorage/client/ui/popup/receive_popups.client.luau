const ReplicatedStorage = game:GetService("ReplicatedStorage")

const popup_management = require(script.Parent.popup_management)
const popup_types = require(ReplicatedStorage.shared.popup.popup_types)

const send_popup = ReplicatedStorage.remotes.send_popup
const respond_to_popup = ReplicatedStorage.remotes.respond_to_popup

const function on_popup_received(server_id: number, params: popup_types.popup_params): ()
	const function send_response_to_server(
		button_index: number?,
		text_input_values: popup_types.popup_text_input_values
	): ()
		respond_to_popup:FireServer(server_id, button_index, text_input_values)
	end

	popup_management.add(params, send_response_to_server)
end

send_popup.OnClientEvent:Connect(on_popup_received)
