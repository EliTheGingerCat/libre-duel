const Players = game:GetService("Players")
const ServerScriptService = game:GetService("ServerScriptService")

const pending_large_notifications = require(script.Parent.pending_large_notifications)
const zap_server_network = require(ServerScriptService.network.zap_server_network)

-- zap guarantees a whole number, only the range is left to check
const function is_valid_button_index(button_index: number?, button_count: number): boolean
	return button_index ~= nil and button_index >= 1 and button_index <= button_count
end

-- button_index is nil when the player closed the notification without pressing a button
const function on_response(player: Player, id: number, button_index: number?): ()
	const pending_large_notification = pending_large_notifications[id]
	if pending_large_notification == nil or pending_large_notification.player ~= player then
		return
	end
	pending_large_notifications[id] = nil

	const on_button_pressed = pending_large_notification.on_button_pressed
	if on_button_pressed == nil or not is_valid_button_index(button_index, pending_large_notification.button_count) then
		return
	end
	-- spawned so an erroring callback cannot break the handler
	task.spawn(on_button_pressed, player, button_index :: number)
end

const function on_player_removing(player: Player): ()
	for id, pending_large_notification in pending_large_notifications do
		if pending_large_notification.player == player then
			pending_large_notifications[id] = nil
		end
	end
end

zap_server_network.respond_to_large_notification.set_callback(on_response)
Players.PlayerRemoving:Connect(on_player_removing)
