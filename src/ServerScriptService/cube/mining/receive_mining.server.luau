const ServerScriptService = game:GetService("ServerScriptService")

const inventory_util = require(ServerScriptService.inventory.inventory_util)
const mine_cube = require(script.Parent.mine_cube)
const zap_server_network = require(ServerScriptService.network.zap_server_network)

const function on_start(player: Player, id: number, cube: Part?, origin: Vector3, direction: Vector3): ()
	const started = inventory_util.has_behaviour(player, "pickaxe")
		and mine_cube.start(player, id, cube, origin, direction)
	if not started then
		zap_server_network.mine_failed.fire(player, id)
	end
end

zap_server_network.mine_cube.set_callback(on_start)
zap_server_network.mine_stop.set_callback(mine_cube.stop)
