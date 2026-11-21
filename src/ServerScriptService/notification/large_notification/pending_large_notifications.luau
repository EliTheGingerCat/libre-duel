export type on_large_notification_button_pressed = (player: Player, button_index: number) -> ()

export type pending_large_notification = {
	player: Player,
	button_count: number,
	on_button_pressed: on_large_notification_button_pressed?,
}

-- notification id -> notification the client has not answered yet
const pending_large_notifications: { [number]: pending_large_notification } = {}

return pending_large_notifications
