const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const dissolve_cube = require(script.Parent.dissolve_cube)
const inventory_util = require(ServerScriptService.inventory.inventory_util)

local function on_start(player: Player, id: unknown, cube: unknown): ()
	const started = inventory_util.has_behaviour(player, "dissolver") and dissolve_cube.start(player, id, cube)
	if not started and type(id) == "number" then
		ReplicatedStorage.remotes.dissolve_failed:FireClient(player, id)
	end
end

local function on_stop(player: Player, id: unknown): ()
	if type(id) == "number" then
		dissolve_cube.stop(player, id)
	end
end

ReplicatedStorage.remotes.dissolve_cube.OnServerEvent:Connect(on_start)
ReplicatedStorage.remotes.dissolve_stop.OnServerEvent:Connect(on_stop)
