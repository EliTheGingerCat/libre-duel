const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const RunService = game:GetService("RunService")
const ServerScriptService = game:GetService("ServerScriptService")

const cube_cache = require(ReplicatedStorage.shared.cube.cube_cache)
const CUBE_MINE_TIME = require(ReplicatedStorage.shared.cube.CUBE_MINE_TIME)
const debug_print = require(ServerScriptService.util.debug_print)
const ENTITY_RANGE_SERVER = require(ServerScriptService.combat.ENTITY_RANGE_SERVER)
const get_entity_position = require(ReplicatedStorage.shared.entity.get_entity_position)
const match = require(ServerScriptService.match.match)
const registry = require(ReplicatedStorage.shared.entity.registry)

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

local function find_mining(entity: registry.entity, id: number): mining?
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

local function mine_ceased(mining: mining): boolean
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

local function mine_finished(mining: mining): ()
	if not mine_ceased(mining) then
		return
	end
	const cube = mining.cube
	cube:Destroy()
	cube_cache[cube.Position] = nil
	if type(mining.entity) ~= "string" then
		ReplicatedStorage.remotes.mine_finished:FireClient(mining.entity, mining.id)
	end
end

local function fire_excluding(remote: RemoteEvent, entity: registry.entity, cube: Part, time_fraction: number): ()
	for _, recipient in Players:GetPlayers() do
		if recipient ~= entity then
			remote:FireClient(recipient, cube, time_fraction)
		end
	end
end

local function mine_progress(mining: mining, time_fraction: number): ()
	fire_excluding(ReplicatedStorage.remotes.mine_progress, mining.entity, mining.cube, time_fraction)
end

local function mine_fail(mining: mining): ()
	debug_print("Failed to mine. Cube:", mining.cube)
	if not mine_ceased(mining) then
		return
	end
	if type(mining.entity) ~= "string" then
		ReplicatedStorage.remotes.mine_failed:FireClient(mining.entity, mining.id)
	end
	mine_progress(mining, 0)
end

local function should_fail(mining: mining): boolean
	const entity_position = get_entity_position(mining.entity)
	if entity_position == nil then
		debug_print("Entity has no position.")
		return true
	end

	const distance = (mining.cube.Position - entity_position).Magnitude
	if distance > ENTITY_RANGE_SERVER then
		debug_print("Entity moved too far away.")
		return true
	end

	return false
end

local function deactivate_heartbeat(): ()
	assert(connection_heartbeat ~= nil, "There is no connection for heartbeat.")
	connection_heartbeat:Disconnect()
	connection_heartbeat = nil
	debug_print("Deactivated the heartbeat connection.")
end

local function on_heartbeat(): ()
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

local function activate_heartbeat(): ()
	if connection_heartbeat == nil then
		connection_heartbeat = RunService.Heartbeat:Connect(on_heartbeat)
	end
end

local function start_mining(entity: registry.entity, id: number, cube: Part): ()
	local mining: mining

	local function on_destroying(): ()
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

local function try_start(entity: registry.entity, id: unknown, cube: unknown): boolean
	-- When dealing with high lag, this can happen if the player places a cube and then immediately begins to mine it. The cube does not exist on the server yet, so the player is simply firing the remote with their local cube.
	if cube == nil then
		debug_print("Not enough arguments. This is likely because the cube does does not exist on the server yet.")
		return false
	end

	if type(id) ~= "number" then
		debug_print("Invalid arguments. Id is not a number.")
		return false
	end

	if typeof(cube) ~= "Instance" then
		debug_print("Invalid arguments. Cube is not an instance.")
		return false
	end

	if not cube:IsA("Part") then
		debug_print("Invalid arguments. Cube is not a Part.")
		return false
	end

	if cube:HasTag("cube") == false then
		debug_print('Cube does not have the "cube" tag, so it is not actually a cube.')
		return false
	end

	const cube_match = match.get_match_of_cube(cube)
	if cube_match and not cube_match.stopped and cube_match ~= match.get_match_of(entity) then
		debug_print("Cube belongs to another match.")
		return false
	end

	const entity_position = get_entity_position(entity)
	if entity_position == nil then
		debug_print("Entity has no position.")
		return false
	end

	const distance = (cube.Position - entity_position).Magnitude
	if distance > ENTITY_RANGE_SERVER then
		debug_print("Too far.")
		return false
	end

	if find_mining(entity, id) ~= nil then
		return false
	end
	start_mining(entity, id, cube)
	return true
end

local function stop(entity: registry.entity, id: number): ()
	const mining = find_mining(entity, id)
	if mining and mine_ceased(mining) then
		mine_progress(mining, 0)
	end
end

local function on_entity_removed(entity: registry.entity): ()
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
