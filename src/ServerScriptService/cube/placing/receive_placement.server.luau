const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const inventory_util = require(ServerScriptService.inventory.inventory_util)
const place_cube = require(script.Parent.place_cube)
const resolve_cube_placement_position = require(script.Parent.resolve_cube_placement_position)
const validate_aim_ray = require(ServerScriptService.aim_validation.validate_aim_ray)

-- the client only says where it aimed, the cell is worked out here
const function on_invoke(player: Player, origin: unknown, direction: unknown): boolean
	-- server's inventory, so exploiters can't spoof the cube (¬‿¬)
	const tool = inventory_util.get_selected_tool(player)
	const cube = if tool ~= nil then tool.behaviours.cube else nil
	if cube == nil then
		return false
	end

	const aim = validate_aim_ray(player, origin, direction)
	if aim == nil then
		return false
	end

	const position = resolve_cube_placement_position(aim)
	if position == nil then
		return false
	end

	return place_cube(player, position, cube)
end

ReplicatedStorage.remotes.place_cube.OnServerInvoke = on_invoke
