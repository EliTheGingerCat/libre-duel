const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const inventory_util = require(ServerScriptService.inventory.inventory_util)
const place_cube = require(script.Parent.place_cube)

local function on_invoke(player: Player, position: unknown): boolean
	if typeof(position) ~= "Vector3" then
		return false
	end
	-- server's inventory, so exploiters can't spoof the cube (¬‿¬)
	const tool = inventory_util.get_selected_tool(player)
	const cube = if tool ~= nil then tool.behaviours.cube else nil
	if cube == nil then
		return false
	end
	return place_cube(player, position, cube)
end

ReplicatedStorage.remotes.place_cube.OnServerInvoke = on_invoke
