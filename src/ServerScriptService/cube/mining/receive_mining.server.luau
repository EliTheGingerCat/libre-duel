const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const mine_cube = require(script.Parent.mine_cube)
const inventory_util = require(ServerScriptService.inventory.inventory_util)

const function on_start(player: Player, id: unknown, cube: unknown): ()
	const started = inventory_util.has_behaviour(player, "pickaxe") and mine_cube.start(player, id, cube)
	if not started and type(id) == "number" then
		ReplicatedStorage.remotes.mine_failed:FireClient(player, id)
	end
end

const function on_stop(player: Player, id: unknown): ()
	if type(id) == "number" then
		mine_cube.stop(player, id)
	end
end

ReplicatedStorage.remotes.mine_cube.OnServerEvent:Connect(on_start)
ReplicatedStorage.remotes.mine_stop.OnServerEvent:Connect(on_stop)
