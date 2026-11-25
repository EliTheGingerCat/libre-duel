const ServerScriptService = game:GetService("ServerScriptService")

const create_protected_remote_handler = require(ServerScriptService.remotes.create_protected_remote_handler)
const inventory_util = require(ServerScriptService.inventory.inventory_util)
const place_cube = require(script.Parent.place_cube)
const resolve_cube_placement_position = require(script.Parent.resolve_cube_placement_position)
const validate_aim_ray = require(ServerScriptService.aim_validation.validate_aim_ray)
const zap_server_network = require(ServerScriptService.network.zap_server_network)

-- the client only says where it aimed, the cell is worked out here
const function on_place_cube(player: Player, origin: Vector3, direction: Vector3): boolean
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

zap_server_network.place_cube.set_callback(create_protected_remote_handler("place_cube", false, on_place_cube))
