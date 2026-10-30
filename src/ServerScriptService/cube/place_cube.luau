const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const add_cooldown = require(ReplicatedStorage.shared.cooldown.add_cooldown)
const create_cube = require(ReplicatedStorage.shared.cube.create_cube)
const cube_cache = require(ReplicatedStorage.shared.cube.cube_cache)
const cube_in_hitbox = require(ReplicatedStorage.shared.cube.cube_in_hitbox)
const debug_print = require(ServerScriptService.util.debug_print)
const ENTITY_RANGE_SERVER = require(ServerScriptService.combat.ENTITY_RANGE_SERVER)
const get_entity_position = require(ReplicatedStorage.shared.entity.get_entity_position)
const get_player_cps = require(ServerScriptService.mitigation.get_player_cps)
const is_on_cooldown = require(ReplicatedStorage.shared.cooldown.is_on_cooldown)
const MITIGATION_CONFIG = require(ServerScriptService.mitigation.MITIGATION_CONFIG)
const play_sound = require(ServerScriptService.util.play_sound)
const registry = require(ReplicatedStorage.shared.entity.registry)
const snap_coordinate = require(ReplicatedStorage.shared.cube.snap_coordinate)

local function verify_coordinate(coordinate: number): boolean
	return coordinate == snap_coordinate(coordinate)
end

local function verify_position(position: Vector3): boolean
	return (verify_coordinate(position.X) and verify_coordinate(position.Y) and verify_coordinate(position.Z))
end

local function place_cube(entity: registry.entity, cube_position: Vector3): boolean
	const entity_position = get_entity_position(entity)
	if entity_position == nil then
		debug_print("Entity has no position.")
		return false
	end

	const distance = (cube_position - entity_position).Magnitude
	if distance > ENTITY_RANGE_SERVER then
		debug_print("Too far.")
		return false
	end

	if not verify_position(cube_position) then
		debug_print("Invalid position.")
		return false
	end

	const occupied_cube = cube_cache[cube_position]
	if occupied_cube then
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

	if
		type(entity) ~= "string"
		and get_player_cps(entity) >= MITIGATION_CONFIG.cps_treshold
		and math.random(1, 100) <= MITIGATION_CONFIG.rejection_chance
	then
		add_cooldown(entity, "place_cube_mitigation", MITIGATION_CONFIG.duration)
		return false
	end

	cube_cache[cube_position] = true

	const clone = create_cube()
	clone.Position = cube_position
	clone.Parent = workspace
	play_sound("cube_place", cube_position)

	return true
end

return place_cube
