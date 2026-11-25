const ReplicatedStorage = game:GetService("ReplicatedStorage")
const RunService = game:GetService("RunService")
const ServerScriptService = game:GetService("ServerScriptService")

const CUBE_MINE_TIME = require(ReplicatedStorage.shared.cube.CUBE_MINE_TIME)
const debug_print = require(ServerScriptService.util.debug_print)
const get_closest_point_on_box = require(ReplicatedStorage.shared.geometry.get_closest_point_on_box)
const get_eye_position = require(ServerScriptService.aim_validation.get_eye_position)
const get_reach = require(ServerScriptService.aim_validation.get_reach)
const is_aiming_at_cube = require(script.Parent.is_aiming_at_cube)
const match = require(ServerScriptService.match.match)
const play_sound = require(ServerScriptService.util.play_sound)
const registry = require(ReplicatedStorage.shared.entity.registry)
const validate_aim_ray = require(ServerScriptService.aim_validation.validate_aim_ray)
const zap_server_network = require(ServerScriptService.network.zap_server_network)

type mining = {
	cube: Part,
	cube_destroying: RBXScriptConnection,
	id: number, -- Unique only to this entity. Ids may overlap among entities.
	entity: registry.entity,
	time_start: number,
	time_end: number,
}

type minings = {
	[registry.entity]: { mining }?,
}

local connection_heartbeat: RBXScriptConnection?
const minings: minings = {}
local total_minings = 0

const function find_mining(entity: registry.entity, id: number): mining?
	const entries = minings[entity]
	if entries == nil then
		return nil
	end
	for _, mining in entries do
		if mining.id == id then
			return mining
		end
	end

	return nil
end

const function mine_ceased(mining: mining): boolean
	const entries = minings[mining.entity]
	const index = if entries then table.find(entries, mining) else nil
	if entries == nil or index == nil then
		return false
	end
	table.remove(entries, index)
	total_minings -= 1
	mining.cube_destroying:Disconnect()
	return true
end

const function mine_finished(mining: mining): ()
	if not mine_ceased(mining) then
		return
	end
	const cube = mining.cube
	play_sound("block_mined", cube.Position)
	cube:Destroy()
	const player = registry.get_player(mining.entity)
	if player then
		zap_server_network.mine_finished.fire(player, mining.id)
	end
end

-- the miner's own client already shows its progress
const function mine_progress(mining: mining, time_fraction: number): ()
	const player = registry.get_player(mining.entity)
	if player then
		zap_server_network.mine_progress.fire_except(player, mining.cube, time_fraction)
	else
		zap_server_network.mine_progress.fire_all(mining.cube, time_fraction)
	end
end

const function mine_fail(mining: mining): ()
	debug_print("Failed to mine. Cube:", mining.cube)
	if not mine_ceased(mining) then
		return
	end
	const player = registry.get_player(mining.entity)
	if player then
		zap_server_network.mine_failed.fire(player, mining.id)
	end
	mine_progress(mining, 0)
end

-- the aim is only checked when mining starts, so while it continues the nearest point of the cube
-- has to stay in reach, which is never further than the point the client is actually aiming at
const function should_fail(mining: mining): boolean
	const eye_position = get_eye_position(mining.entity)
	if eye_position == nil then
		debug_print("Entity has no position.")
		return true
	end

	const closest_point = get_closest_point_on_box(eye_position, mining.cube.CFrame, mining.cube.Size)
	const reach, is_in_reach = get_reach(eye_position, closest_point)
	if not is_in_reach then
		debug_print("Entity moved too far away:", reach)
		return true
	end

	return false
end

const function deactivate_heartbeat(): ()
	assert(connection_heartbeat ~= nil, "There is no connection for heartbeat.")
	connection_heartbeat:Disconnect()
	connection_heartbeat = nil
	debug_print("Deactivated the heartbeat connection.")
end

const function on_heartbeat(): ()
	const now = os.clock()
	const finished: { mining } = {}
	const failed: { mining } = {}

	for _, entity_minings in minings do
		if entity_minings == nil then
			continue
		end
		for _, mining in entity_minings do
			if mining.time_end <= now then
				table.insert(finished, mining)
				continue
			end

			if should_fail(mining) == true then
				table.insert(failed, mining)
				continue
			end

			const time_elapsed = now - mining.time_start
			const time_fraction = time_elapsed / CUBE_MINE_TIME
			mine_progress(mining, time_fraction)
		end
	end

	-- I read somewhere that it is bad to alter a table while iterating through it.
	for _, mining in finished do
		mine_finished(mining)
	end

	for _, mining in failed do
		mine_fail(mining)
	end

	if total_minings == 0 then
		deactivate_heartbeat()
	end
end

const function activate_heartbeat(): ()
	if connection_heartbeat == nil then
		connection_heartbeat = RunService.Heartbeat:Connect(on_heartbeat)
	end
end

const function start_mining(entity: registry.entity, id: number, cube: Part): ()
	local mining: mining

	const function on_destroying(): ()
		mine_fail(mining)
	end
	const connection_destroying = cube.Destroying:Connect(on_destroying)

	mining = {
		cube = cube,
		cube_destroying = connection_destroying,
		id = id,
		entity = entity,
		time_start = os.clock(), -- Can be bad for laggy players.
		time_end = os.clock() + CUBE_MINE_TIME,
	}
	const entries = minings[entity] or {}
	minings[entity] = entries
	table.insert(entries, mining)
	total_minings += 1

	activate_heartbeat()
end

const function try_start(player: Player, id: number, cube: Part?, origin: Vector3, direction: Vector3): boolean
	-- When dealing with high lag, this can happen if the player places a cube and then immediately begins to mine it. The cube does not exist on the server yet, so the player is simply firing the remote with their local cube.
	if cube == nil then
		debug_print("The cube is missing. This is likely because the cube does does not exist on the server yet.")
		return false
	end

	if cube:HasTag("cube") == false then
		debug_print('Cube does not have the "cube" tag, so it is not actually a cube.')
		return false
	end

	const cube_match = match.get_match_of_cube(cube)
	if cube_match and not cube_match.stopped and cube_match ~= match.get_match_of(player) then
		debug_print("Cube belongs to another match.")
		return false
	end

	const aim = validate_aim_ray(player, origin, direction)
	if aim == nil or not is_aiming_at_cube(aim, cube) then
		return false
	end

	if find_mining(player, id) ~= nil then
		return false
	end
	start_mining(player, id, cube)
	return true
end

const function stop(entity: registry.entity, id: number): ()
	const mining = find_mining(entity, id)
	if mining and mine_ceased(mining) then
		mine_progress(mining, 0)
	end
end

const function on_entity_removed(entity: registry.entity): ()
	const entries = minings[entity]
	if entries == nil then
		return
	end
	for _, mining in entries do
		mining.cube_destroying:Disconnect()
		mine_progress(mining, 0)
		total_minings -= 1
	end
	minings[entity] = nil
end

registry.removed:Connect(on_entity_removed)

return {
	start = try_start,
	stop = stop,
}
