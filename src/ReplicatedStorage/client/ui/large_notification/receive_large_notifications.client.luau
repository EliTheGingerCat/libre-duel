const ReplicatedStorage = game:GetService("ReplicatedStorage")

const large_notification_management = require(script.Parent.large_notification_management)
const large_notification_types = require(ReplicatedStorage.shared.large_notification.large_notification_types)
const zap_client_network = require(ReplicatedStorage.client.network.zap_client_network)

const function on_large_notification_received(
	server_id: number,
	params: large_notification_types.large_notification_params
): ()
	const function send_response_to_server(button_index: number?): ()
		zap_client_network.respond_to_large_notification.fire(server_id, button_index)
	end

	large_notification_management.add(params, send_response_to_server)
end

zap_client_network.send_large_notification.set_callback(on_large_notification_received)
