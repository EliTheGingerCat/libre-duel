const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const RunService = game:GetService("RunService")
const ServerScriptService = game:GetService("ServerScriptService")

const cube_cache = require(ReplicatedStorage.shared.cube.cube_cache)
const CUBE_DISSOLVE_TIME = require(ReplicatedStorage.shared.cube.CUBE_DISSOLVE_TIME)
const debug_print = require(ServerScriptService.util.debug_print)
const ENTITY_RANGE_SERVER = require(ServerScriptService.combat.ENTITY_RANGE_SERVER)
const get_entity_position = require(ReplicatedStorage.shared.entity.get_entity_position)
const registry = require(ReplicatedStorage.shared.entity.registry)

type dissolving = {
	cube: Part,
	cube_destroying: RBXScriptConnection,
	id: number, -- Unique only to this entity. Ids may overlap among entities.
	entity: registry.entity,
	time_start: number,
	time_end: number,
}

type dissolvings = {
	[registry.entity]: { dissolving }?,
}

local connection_heartbeat: RBXScriptConnection?
const dissolvings: dissolvings = {}
local total_dissolvings = 0

local function find_dissolving(entity: registry.entity, id: number): dissolving?
	const entries = dissolvings[entity]
	if entries == nil then
		return nil
	end
	for _, dissolving in entries do
		if dissolving.id == id then
			return dissolving
		end
	end

	return nil
end

local function dissolve_ceased(dissolving: dissolving): boolean
	const entries = dissolvings[dissolving.entity]
	const index = if entries then table.find(entries, dissolving) else nil
	if entries == nil or index == nil then
		return false
	end
	table.remove(entries, index)
	total_dissolvings -= 1
	dissolving.cube_destroying:Disconnect()
	return true
end

local function dissolve_finished(dissolving: dissolving): ()
	if not dissolve_ceased(dissolving) then
		return
	end
	const cube = dissolving.cube
	cube:Destroy()
	cube_cache[cube.Position] = nil
	if type(dissolving.entity) ~= "string" then
		ReplicatedStorage.remotes.dissolve_finished:FireClient(dissolving.entity, dissolving.id)
	end
end

local function fire_excluding(remote: RemoteEvent, entity: registry.entity, cube: Part, time_fraction: number): ()
	for _, recipient in Players:GetPlayers() do
		if recipient ~= entity then
			remote:FireClient(recipient, cube, time_fraction)
		end
	end
end

local function dissolve_progress(dissolving: dissolving, time_fraction: number): ()
	fire_excluding(ReplicatedStorage.remotes.dissolve_progress, dissolving.entity, dissolving.cube, time_fraction)
end

local function dissolve_fail(dissolving: dissolving): ()
	debug_print("Failed to dissolve. Cube:", dissolving.cube)
	if not dissolve_ceased(dissolving) then
		return
	end
	if type(dissolving.entity) ~= "string" then
		ReplicatedStorage.remotes.dissolve_failed:FireClient(dissolving.entity, dissolving.id)
	end
	dissolve_progress(dissolving, 0)
end

local function should_fail(dissolving: dissolving): boolean
	const entity_position = get_entity_position(dissolving.entity)
	if entity_position == nil then
		debug_print("Entity has no position.")
		return true
	end

	const distance = (dissolving.cube.Position - entity_position).Magnitude
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
	const now = tick()
	const finished: { dissolving } = {}
	const failed: { dissolving } = {}

	for _, entity_dissolvings in dissolvings do
		if entity_dissolvings == nil then
			continue
		end
		for _, dissolving in entity_dissolvings do
			if dissolving.time_end <= now then
				table.insert(finished, dissolving)
				continue
			end

			if should_fail(dissolving) == true then
				table.insert(failed, dissolving)
				continue
			end

			const time_elapsed = now - dissolving.time_start
			const time_fraction = time_elapsed / CUBE_DISSOLVE_TIME
			dissolve_progress(dissolving, time_fraction)
		end
	end

	-- I read somewhere that it is bad to alter a table while iterating through it.
	for _, dissolving in finished do
		dissolve_finished(dissolving)
	end

	for _, dissolving in failed do
		dissolve_fail(dissolving)
	end

	if total_dissolvings == 0 then
		deactivate_heartbeat()
	end
end

local function activate_heartbeat(): ()
	if connection_heartbeat == nil then
		connection_heartbeat = RunService.Heartbeat:Connect(on_heartbeat)
	end
end

local function start_dissolving(entity: registry.entity, id: number, cube: Part): ()
	local dissolving: dissolving

	local function on_destroying(): ()
		dissolve_fail(dissolving)
	end
	const connection_destroying = cube.Destroying:Connect(on_destroying)

	dissolving = {
		cube = cube,
		cube_destroying = connection_destroying,
		id = id,
		entity = entity,
		time_start = tick(), -- Can be bad for laggy players.
		time_end = tick() + CUBE_DISSOLVE_TIME,
	}
	const entries = dissolvings[entity] or {}
	dissolvings[entity] = entries
	table.insert(entries, dissolving)
	total_dissolvings += 1

	activate_heartbeat()
end

local function try_start(entity: registry.entity, id: unknown, cube: unknown): boolean
	-- When dealing with high lag, this can happen if the player places a cube and then immediately begins to dissolve it. The cube does not exist on the server yet, so the player is simply firing the remote with their local cube.
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

	if find_dissolving(entity, id) ~= nil then
		return false
	end
	start_dissolving(entity, id, cube)
	return true
end

local function stop(entity: registry.entity, id: number): ()
	const dissolving = find_dissolving(entity, id)
	if dissolving and dissolve_ceased(dissolving) then
		dissolve_progress(dissolving, 0)
	end
end

local function on_entity_removed(entity: registry.entity): ()
	const entries = dissolvings[entity]
	if entries == nil then
		return
	end
	for _, dissolving in entries do
		dissolving.cube_destroying:Disconnect()
		dissolve_progress(dissolving, 0)
		total_dissolvings -= 1
	end
	dissolvings[entity] = nil
end

registry.removed:Connect(on_entity_removed)

return {
	start = try_start,
	stop = stop,
}
