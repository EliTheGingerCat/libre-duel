const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const inventory_util = require(ServerScriptService.inventory.inventory_util)
const place_cube = require(script.Parent.place_cube)

local function on_invoke(player: Player, position: unknown, tool_id: unknown): boolean
	if typeof(position) ~= "Vector3" or type(tool_id) ~= "string" then
		return false
	end
	if not inventory_util.has_tool(player, tool_id) then
		return false
	end
	return place_cube(player, position, tool_id)
end

ReplicatedStorage.remotes.place_cube.OnServerInvoke = on_invoke
