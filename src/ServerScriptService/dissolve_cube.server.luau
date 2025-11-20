local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local cube_cache = require(ReplicatedStorage.modules.cube_cache)
local cube_dissolve_time = require(ReplicatedStorage.modules.cube_dissolve_time)
local debug_print = require(script.Parent.modules.debug_print)
local get_player_position = require(ReplicatedStorage.modules.get_player_position)
local player_range_server = require(ServerScriptService.modules.player_range_server)

type dissolving = {
	cube: Part,
	cube_destroying: RBXScriptConnection,
	player: Player,
	time_start: number,
	time_end: number,
}

type dissolvings = {
	[Player]: dissolving,
}

local connection_heartbeat: RBXScriptConnection?
local dissolvings: dissolvings = {}

local function dissolve_ceased(dissolving: dissolving): ()
	dissolvings[dissolving.player] = nil
	dissolving.cube_destroying:Disconnect()
end

local function dissolve_finished(dissolving: dissolving): ()
	dissolve_ceased(dissolving)
	local cube = dissolving.cube
	cube:Destroy()
	cube_cache[cube.Position] = nil
	ReplicatedStorage.remotes.dissolve_finished:FireClient(dissolving.player)
end

local function fire_excluding(remote: RemoteEvent, player: Player, ...: any): ()
	for _, some_player in Players:GetPlayers() do
		if some_player ~= player then
			remote:FireClient(player, ...)
		end
	end
end

local function dissolve_progress(dissolving: dissolving, time_fraction: number): ()
	fire_excluding(ReplicatedStorage.remotes.dissolve_progress, dissolving.player, dissolving.cube, time_fraction)
end

local function dissolve_fail(dissolving: dissolving): ()
	debug_print("Failed to dissolve. Cube:", dissolving.cube)
	dissolve_ceased(dissolving)
	ReplicatedStorage.remotes.dissolve_failed:FireClient(dissolving.player)
	dissolve_progress(dissolving, 0)
end

local function should_fail(dissolving: dissolving): boolean
	local player_position = get_player_position(dissolving.player)
	if player_position == nil then
		debug_print("User has no position.")
		return true
	end

	local distance = (dissolving.cube.Position - player_position).Magnitude
	if distance > player_range_server then
		debug_print("User moved too far away.")
		return true
	end

	return false
end

local function is_empty(tab: {[any]: any}): boolean
	local next_index = next(tab)
	local empty = next_index == nil
	return empty
end

local function deactivate_heartbeat(): ()
	assert(connection_heartbeat ~= nil, "There is no connection for heartbeat.")
	connection_heartbeat:Disconnect()
	connection_heartbeat = nil
end

local function on_heartbeat(): ()
	local now = tick()
	local finished: {dissolving} = {}
	local failed: {dissolving} = {}

	for _, dissolving in dissolvings do
		if dissolving.time_end <= now then
			table.insert(finished, dissolving)
			continue
		end

		if should_fail(dissolving) == true then
			table.insert(failed, dissolving)
			continue
		end

		local time_elapsed = now - dissolving.time_start
		local time_fraction = time_elapsed / cube_dissolve_time
		dissolve_progress(dissolving, time_fraction)
	end

	-- I read somewhere that it is bad to alter a table while iterating through it.
	for _, dissolving in finished do
		dissolve_finished(dissolving)
	end

	for _, dissolving in failed do
		dissolve_fail(dissolving)
	end

	if is_empty(dissolvings) == true then
		deactivate_heartbeat()
	end
end

local function activate_heartbeat(): ()
	if connection_heartbeat == nil then
		connection_heartbeat = RunService.Heartbeat:Connect(on_heartbeat)
	end
end

local function start_dissolving(player: Player, cube: Part): ()
	local dissolving: dissolving

	local function on_destroying(): ()
		dissolve_fail(dissolving)
	end
	local connection_destroying = cube.Destroying:Connect(on_destroying)

	dissolving = {
		cube = cube,
		cube_destroying = connection_destroying,
		player = player,
		time_start = tick(), -- Can be bad for laggy players.
		time_end = tick() + cube_dissolve_time,
	}
	dissolvings[player] = dissolving
	activate_heartbeat()
end

local function try_start(player: Player, cube: unknown?): boolean
	-- When dealing with high lag, this can happen if the player places a cube and then immediately begins to dissolve it. The cube does not exist on the server yet, so the player is simply firing the remote with their local cube.
	if cube == nil then
		debug_print("Not enough arguments. This is likely because the cube does does not exist on the server yet.")
		return false
	end
	
	if typeof(cube) ~= "Instance" then
		debug_print("Invalid arguments. Not an instance.")
		return false
	end

	if not cube:IsA("Part") then
		debug_print("Invalid arguments. Not a Part.")
		return false
	end

	if cube:HasTag("cube") == false then
		debug_print("Cube does not have the \"cube\" tag, so it is not actually a cube.")
		return false
	end

	local player_position = get_player_position(player)
	if player_position == nil then
		debug_print("Player has no position.")
		return false
	end

	local distance = (cube.Position - player_position).Magnitude
	if distance > player_range_server then
		debug_print("Too far.")
		return false
	end

	start_dissolving(player, cube)
	return true
end

local function on_fire_start(player: Player, cube: unknown?): ()
	local success = try_start(player, cube)
	if success == false then
		ReplicatedStorage.remotes.dissolve_failed:FireClient(player)
	end
end

local function on_fire_stop(player: Player): ()
	local dissolving = dissolvings[player]
	
	-- This function can be fired willy-nilly by players, so there is no guarantee that the player is actually dissolving anything. It can also be nil for honest players if they are experiencing great lag: they place a block, then start dissolving, but the server denies the dissolving because the block does not exist on the server yet.
	if dissolving == nil then
		return
	end

	dissolve_ceased(dissolving)
end


ReplicatedStorage.remotes.dissolve_cube.OnServerEvent:Connect(on_fire_start)
ReplicatedStorage.remotes.dissolve_stop.OnServerEvent:Connect(on_fire_stop)
