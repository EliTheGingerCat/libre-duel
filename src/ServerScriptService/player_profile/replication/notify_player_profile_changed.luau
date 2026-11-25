const ServerScriptService = game:GetService("ServerScriptService")

const zap_server_network = require(ServerScriptService.network.zap_server_network)

-- tells the player their own profile changed so an open profile menu fetches it again
const function notify_player_profile_changed(player: Player): ()
	zap_server_network.player_profile_changed.fire(player)
end

return notify_player_profile_changed
