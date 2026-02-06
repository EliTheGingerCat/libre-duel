local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local cube_cache = require(ReplicatedStorage.modules.cube_cache)
local cube_dissolve_time = require(ReplicatedStorage.modules.cube_dissolve_time)
local debug_print = require(script.Parent.debug_print)
local keybinds = require(script.Parent.keybinds)
local get_player_position = require(ReplicatedStorage.modules.get_player_position)
local player_range = require(ReplicatedStorage.modules.player_range)
local transparency_maximum = require(script.Parent.transparency_maximum)

local local_player = Players.LocalPlayer
local local_mouse = local_player:GetMouse()

local connection_input: RBXScriptConnection?
local connection_heartbeat_passive: RBXScriptConnection?

-- This whole id system is probably not necessary since RemoteEvent communication travels in order and Luau is single-threaded, but this system is already so complicated that I want this as a safeguard against insanity.
local id = 0

-- While waiting for the server's response.
type state_pending = {
	connection_destroying: RBXScriptConnection,
	cube_target: Part,
	id: number,
}

-- While the cube is not dissolved on the client.
type state_local = {
	connection_destroying: RBXScriptConnection,
	connection_heartbeat: RBXScriptConnection,
	cube_target: Part,
	id: number,
	last_fail: string?,
	time_start: number,
}

type state_any = state_local | state_pending

local dissolvings: {state_any} = {}
local local_dissolving: state_local?

local function find_by_id(id: number): state_any?
	for _, state in dissolvings do
		if state.id == id then
			return state
		end
	end

	debug_print(`There is no state with id "{id}".`)
	return nil
end

local function remove_by_id(id: number): ()
	for index, state in dissolvings do
		if state.id == id then
			dissolvings[index] = nil
			return
		end
	end

	debug_print(`There is no state with id "{id}".`)
end

local function cleanup_local(state: state_local): state_pending
	local_dissolving = nil
	
	state.connection_heartbeat:Disconnect()

	local state_pending = {
		connection_destroying = state.connection_destroying,
		cube_target = state.cube_target,
		id = state.id,
	}

	return state_pending
end

local function cleanup_pending(state: state_pending): ()
	state.connection_destroying:Disconnect()
	-- The state is now dead.
	remove_by_id(state.id)
end

-- Destroys the state.
local function cleanup_all(state: state_local): ()
	cleanup_local(state)
	cleanup_pending(state)
end

local function set_dissolution_display(state: state_any, fraction: number): ()
	state.cube_target.Transparency = fraction
end

local function dissolve_pause(state: state_local): ()
	set_dissolution_display(state, 0)
	ReplicatedStorage.remotes.dissolve_stop:FireServer(state.id)
end

local function dissolve_stop(state: state_local): ()
	dissolve_pause(state) -- Must pause before cleaning up the cube pointer.
	cleanup_all(state)
end

local dissolve_start
local function dissolve_new_cube(state: state_local, cube: Part): ()
	dissolve_stop(state)
	dissolve_start(cube)
end

local function on_heartbeat_passive(): ()
	local cube = local_mouse.Target
	dissolve_start(cube)
end

local function activate_heartbeat_passive(): ()
	connection_heartbeat_passive = RunService.Heartbeat:Connect(on_heartbeat_passive)
end

local function disable_heartbeat_passive(): ()
	if connection_heartbeat_passive ~= nil then
		connection_heartbeat_passive:Disconnect()
		connection_heartbeat_passive = nil
	end
end

local function local_dissolving_finished(state: state_local): ()
	state.cube_target.Parent = nil
	cleanup_local(state)

	activate_heartbeat_passive()
end

local function on_input_ended(input: InputObject): ()
	if input.UserInputType == keybinds.tool_use then
		if local_dissolving then
			dissolve_stop(local_dissolving)
		end

		disable_heartbeat_passive()

		assert(connection_input, "language analysis")
		connection_input:Disconnect()
		connection_input = nil
	end
end

-- If the return value is false, the client will stop dissolving.
local function can_dissolve(cube: Part?, do_print: true?): string?
	if cube == nil then
		return "Mouse is not pointing at anything."
	end

	if not cube:IsA("Part") then
		return "Mouse target is not a Part."
	end
	
	if cube:HasTag("cube") == false then
		return "Mouse target is not a cube."
	end

	local local_position = get_player_position(local_player)
	if local_position == nil then
		return "Local position is missing."
	end

	local distance = (cube.Position - local_position).Magnitude
	if distance > player_range then
		return "Too far."
	end

	return nil
end

local function on_heartbeat_active(): ()
	local state = assert(local_dissolving, "Local dissolving is missing.")
	
	local cube_now = local_mouse.Target
	local fail_message = can_dissolve(cube_now)
	local fail = fail_message ~= nil
	if fail == true then
		-- As this runs every Heartbeat, do not spam the fail message nor the pausing.
		if fail_message ~= state.last_fail then
			state.last_fail = fail_message
			debug_print(fail_message)

			dissolve_pause(state)
		end

		-- Maybe whatever is preventing dissolution will cease. Do not stop dissolving --- keep checking. Only releasing of the keybind should stop all operations.
		-- Technically, some more connections could be added to reduce the amount of work every frame. For example, if `local_mouse.Target` has not changed since last frame, and it was problematic in the last frame, then it is certainly problematic in this frame, though that seems overly complicated for not much benefit and in an already complicated system.
		return
	end

	-- An example of when this would be `true` is if the player starts dissolving a cube, moves their mouse away from it, and then moves it back on. During the time that the mouse was away, `can_dissolve` reported a specific fail message and the dissolving was paused.
	local unpaused = state.last_fail ~= nil
	if unpaused then
		dissolve_new_cube(state, cube_now)
		return
	end
	state.last_fail = nil

	if cube_now ~= state.cube_target then
		dissolve_new_cube(state, cube_now)
		return
	end

	local time_elapsed = tick() - state.time_start
	local time_fraction = math.min(1, time_elapsed / cube_dissolve_time)
	-- See `transparency_maximum.luau` for an explanation of this operation.
	local transparency_fraction = time_fraction * transparency_maximum
	set_dissolution_display(state, transparency_fraction)

	if time_fraction >= 1 then
		local_dissolving_finished(state)
	end
end

dissolve_start = function(cube: Part): ()
	local fail_message = can_dissolve(cube)
	local failed = fail_message ~= nil
	if failed == true then
		debug_print(`Failed to start dissolving: {fail_message}`)
		return
	end

	disable_heartbeat_passive()

	if connection_input == nil then
		connection_input = UserInputService.InputEnded:Connect(on_input_ended)
	end

	id += 1

	local cube_target = cube
	local connection_heartbeat = RunService.Heartbeat:Connect(on_heartbeat_active)
	local time_start = tick()

	-- This connection is always made, even when debug mode is disabled.
	local function on_destroying(): ()
		debug_print("Destroying cube:", cube)
	end
	local connection_destroying = cube.Destroying:Connect(on_destroying)

	local state: state_local = {
		connection_destroying = connection_destroying,
		connection_heartbeat = connection_heartbeat,
		cube_target = cube_target,
		id = id,
		last_fail = nil,
		time_start = time_start,
	}

	table.insert(dissolvings, state)

	assert(local_dissolving == nil, "A local dissolving is already active.")
	local_dissolving = state

	ReplicatedStorage.remotes.dissolve_cube:FireServer(id, cube)
end

local function on_dissolve_suceeded(id: number): ()
	local state: state_pending? = find_by_id(id)
	if state == nil then
		return
	end

	local position = state.cube_target.Position
	-- Players can only place a cube in a previously occupied position after the cube is dissolved on the server.
	cube_cache[position] = nil
	cleanup_pending(state)
end

local function on_dissolve_failed(id: number): ()
	local state: state_pending? = find_by_id(id)
	if state == nil then
		return
	end
	
	set_dissolution_display(state, 0)
	state.cube_target.Parent = workspace
	debug_print("Server reported failure. Local cube was returned.")
	cleanup_pending(state)
end

ReplicatedStorage.remotes.dissolve_finished.OnClientEvent:Connect(on_dissolve_suceeded)
ReplicatedStorage.remotes.dissolve_failed.OnClientEvent:Connect(on_dissolve_failed)

return activate_heartbeat_passive
