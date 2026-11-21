const ReplicatedStorage = game:GetService("ReplicatedStorage")

const large_notification_types = require(ReplicatedStorage.shared.large_notification.large_notification_types)
const pending_large_notifications = require(script.Parent.pending_large_notifications)

const send_large_notification_remote = ReplicatedStorage.remotes.send_large_notification

local current_id = 0

-- on_button_pressed gets the index of the pressed button in params.buttons
const function send_large_notification(
	player: Player,
	params: large_notification_types.large_notification_params,
	on_button_pressed: pending_large_notifications.on_large_notification_button_pressed?
): ()
	current_id += 1

	pending_large_notifications[current_id] = {
		player = player,
		button_count = if params.buttons then #params.buttons else 0,
		on_button_pressed = on_button_pressed,
	}
	send_large_notification_remote:FireClient(player, current_id, params)
end

return send_large_notification
