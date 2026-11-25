-- This is the pong side

const ServerScriptService = game:GetService("ServerScriptService")

const zap_server_network = require(ServerScriptService.network.zap_server_network)

const function on_ping(player: Player): ()
	zap_server_network.pong.fire(player)
end

zap_server_network.ping.set_callback(on_ping)
