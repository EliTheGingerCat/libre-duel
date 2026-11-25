const ServerScriptService = game:GetService("ServerScriptService")

const zap_server_network = require(ServerScriptService.network.zap_server_network)

const function send_notification(player: Player | "all", message: string): ()
	if player == "all" then
		zap_server_network.send_notification.fire_all(message)
		return
	end
	zap_server_network.send_notification.fire(player, message)
end

return send_notification
