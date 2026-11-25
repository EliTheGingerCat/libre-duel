local ServerScriptService = game:GetService("ServerScriptService")

const zap_server_network = require(ServerScriptService.network.zap_server_network)

const function play_sound(name: string, position: Vector3): ()
	zap_server_network.play_sound.fire_all(name, position)
end

return play_sound
