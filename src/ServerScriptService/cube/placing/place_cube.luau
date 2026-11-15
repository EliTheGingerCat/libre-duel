const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const add_cooldown = require(ReplicatedStorage.shared.cooldown.add_cooldown)
const create_cube = require(ReplicatedStorage.shared.cube.create_cube)
const cube_cache = require(ReplicatedStorage.shared.cube.cube_cache)
const cube_in_hitbox = require(ReplicatedStorage.shared.cube.cube_in_hitbox)
const debug_print = require(ServerScriptService.util.debug_print)
const inventory_util = require(ServerScriptService.inventory.inventory_util)
const is_building_allowed = require(ServerScriptService.cube.building_restrictions.is_building_allowed)
const get_player_cps = require(ServerScriptService.cps.get_player_cps)
const match = require(ServerScriptService.match.match)
const send_notification = ReplicatedStorage.remotes.send_notification
const is_on_cooldown = require(ReplicatedStorage.shared.cooldown.is_on_cooldown)
const MITIGATION_CONFIG = require(ServerScriptService.mitigation.MITIGATION_CONFIG)
const play_sound = require(ServerScriptService.util.play_sound)
const registry = require(ReplicatedStorage.shared.entity.registry)
const snap_coordinate = require(ReplicatedStorage.shared.cube.snap_coordinate)
const tool_types = require(ReplicatedStorage.shared.tools.tool_types)

const function verify_coordinate(coordinate: number): boolean
	return coordinate == snap_coordinate(coordinate)
end

const function verify_position(position: Vector3): boolean
	return (verify_coordinate(position.X) and verify_coordinate(position.Y) and verify_coordinate(position.Z))
end

-- reach isn't checked here, the position has to come from resolve_cube_placement_position
const function place_cube(entity: registry.entity, cube_position: Vector3, appearance: tool_types.cube_params): boolean
	if not verify_position(cube_position) then
		debug_print("Invalid position.")
		return false
	end

	if not is_building_allowed(cube_position) then
		debug_print("The player cannot build here.")
		registry.fire_client(
			entity,
			send_notification,
			'<font color="rgb(255, 84, 84)">You cannot place cubes here!</font>'
		)
		return false
	end

	if cube_cache.is_occupied(cube_position) then
		debug_print("Occupied by cube.")
		return false
	end

	const occupied_entity = cube_in_hitbox(cube_position, entity)
	if occupied_entity then
		debug_print("Occupied by entity.")
		return false
	end

	if is_on_cooldown(entity, "place_cube_mitigation") then
		debug_print("Entity is mitigated.")
		return false
	end

	const player = registry.get_player(entity)
	if
		player
		and get_player_cps(player) >= MITIGATION_CONFIG.cps_treshold
		and math.random(1, 100) <= MITIGATION_CONFIG.rejection_chance
	then
		add_cooldown(entity, "place_cube_mitigation", MITIGATION_CONFIG.duration)
		return false
	end

	const clone = create_cube(appearance)
	clone.Position = cube_position
	clone.Parent = workspace.runtime_instances.cubes
	-- The tag signal may be deferred, which would let a second placement in the same frame pass the occupancy check
	cube_cache.track(clone)
	const entity_match = match.get_match_of(entity)
	if entity_match then
		match.track_cube(entity_match, clone)
	end
	inventory_util.consume_selected_item(entity)
	play_sound("cube_place", cube_position)

	return true
end

return place_cube
