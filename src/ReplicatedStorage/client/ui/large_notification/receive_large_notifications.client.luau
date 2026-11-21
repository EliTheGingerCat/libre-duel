const ReplicatedStorage = game:GetService("ReplicatedStorage")

const large_notification_management = require(script.Parent.large_notification_management)
const large_notification_types = require(ReplicatedStorage.shared.large_notification.large_notification_types)

const send_large_notification = ReplicatedStorage.remotes.send_large_notification
const respond_to_large_notification = ReplicatedStorage.remotes.respond_to_large_notification

const function on_large_notification_received(
	server_id: number,
	params: large_notification_types.large_notification_params
): ()
	const function send_response_to_server(button_index: number?): ()
		respond_to_large_notification:FireServer(server_id, button_index)
	end

	large_notification_management.add(params, send_response_to_server)
end

send_large_notification.OnClientEvent:Connect(on_large_notification_received)
