local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local cube_cache = require(ReplicatedStorage.shared.cube.cube_cache)
local set_cube_transparency = require(ReplicatedStorage.shared.cube.set_cube_transparency)
const CUBE_MINE_TIME = require(ReplicatedStorage.shared.cube.CUBE_MINE_TIME)
local debug_print = require(ReplicatedStorage.client.util.debug_print)
const ENTITY_RANGE = require(ReplicatedStorage.shared.combat.ENTITY_RANGE)
local get_entity_position = require(ReplicatedStorage.shared.entity.get_entity_position)
const KEYBINDS = require(ReplicatedStorage.client.util.KEYBINDS)
const TRANSPARENCY_MAXIMUM = require(ReplicatedStorage.client.cube.TRANSPARENCY_MAXIMUM)

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

-- While the cube is not mined on the client.
type state_local = {
	connection_destroying: RBXScriptConnection,
	connection_heartbeat: RBXScriptConnection,
	cube_target: Part,
	id: number,
	last_fail: string?,
	time_start: number,
}

type state_any = state_local | state_pending

local minings: { state_any } = {}
local local_mining: state_local?

local function find_by_id(id: number): state_any?
	for _, state in minings do
		if state.id == id then
			return state
		end
	end

	debug_print(`Error: There is no state with id "{id}".`)
	return nil
end

local function remove_by_id(id: number): ()
	for index, state in minings do
		if state.id == id then
			minings[index] = nil
			return
		end
	end

	debug_print(`Error: There is no state with id "{id}".`)
end

-- The state_local `state` must not be used after this point.
local function cleanup_local(state: state_local): state_pending
	local_mining = nil

	state.connection_heartbeat:Disconnect()

	local state_pending = {
		connection_destroying = state.connection_destroying,
		cube_target = state.cube_target,
		id = state.id,
	}

	return state_pending
end

-- The pending `state` must not be used after this point.
local function cleanup_pending(state: state_pending): ()
	state.connection_destroying:Disconnect()
	remove_by_id(state.id)
end

-- Destroys the state.
local function cleanup_all(state: state_local): ()
	local state_pending = cleanup_local(state)
	cleanup_pending(state_pending)
end

local function set_mining_display(state: state_any, fraction: number): ()
	set_cube_transparency(state.cube_target, fraction)
end

local function mine_pause(state: state_local): ()
	set_mining_display(state, 0)
	ReplicatedStorage.remotes.mine_stop:FireServer(state.id)
end

local function mine_stop(state: state_local): ()
	mine_pause(state) -- Must pause before cleaning up the cube pointer.
	cleanup_all(state)
end

local mine_start
local function mine_new_cube(state: state_local, cube: BasePart): ()
	mine_stop(state)
	mine_start(cube)
end

local function on_heartbeat_passive(): ()
	local cube = local_mouse.Target
	mine_start(cube)
end

local activate_input_ended
local function activate_heartbeat_passive(): ()
	connection_heartbeat_passive = RunService.Heartbeat:Connect(on_heartbeat_passive)
	activate_input_ended()
	debug_print("Activated passive heartbeat.")
end

local function disable_heartbeat_passive(): ()
	if connection_heartbeat_passive ~= nil then
		connection_heartbeat_passive:Disconnect()
		connection_heartbeat_passive = nil
	end
end

local function local_mining_finished(state: state_local): ()
	state.cube_target.Parent = nil
	cleanup_local(state)

	activate_heartbeat_passive()
end

local function on_input_ended(input: InputObject): ()
	if input.UserInputType == KEYBINDS.tool_use then
		if local_mining ~= nil then
			mine_stop(local_mining)
		end

		disable_heartbeat_passive()

		assert(connection_input, "language analysis")
		connection_input:Disconnect()
		connection_input = nil
	end
end

function activate_input_ended(): ()
	if connection_input ~= nil then
		debug_print("`input_ended` is already connected.")
		return
	end

	connection_input = UserInputService.InputEnded:Connect(on_input_ended)
end

-- If the return value is false, the client will stop mining.
local function can_mine(cube: Instance?): string?
	if cube == nil then
		return "Mouse is not pointing at anything."
	end

	if not cube:IsA("Part") then
		return "Mouse target is not a Part."
	end

	if cube:HasTag("cube") == false then
		return "Mouse target is not a cube."
	end

	local local_position = get_entity_position(local_player)
	if local_position == nil then
		return "Local position is missing."
	end

	local distance = (cube.Position - local_position).Magnitude
	if distance > ENTITY_RANGE then
		return "Too far."
	end

	return nil
end

local function on_heartbeat_active(): ()
	local state = local_mining
	if state == nil then
		debug_print("Error: Local mining is missing.")
		return
	end

	local cube_now = local_mouse.Target
	local fail_message = can_mine(cube_now)
	local fail = fail_message ~= nil
	if fail == true then
		-- As this runs every Heartbeat, do not spam the fail message nor the pausing.
		if fail_message ~= state.last_fail then
			if state.last_fail == nil then
				-- This is the first time the mining has failed since it started or since it last resumed (if it paused).
				mine_pause(state)
			end
			state.last_fail = fail_message
			debug_print(fail_message)
		end

		-- Maybe whatever is preventing mining will cease. Do not stop mining --- keep checking. Only releasing of the keybind should stop all operations.
		-- Technically, some more connections could be added to reduce the amount of work every frame. For example, if `local_mouse.Target` has not changed since last frame, and it was problematic in the last frame, then it is certainly problematic in this frame, though that seems overly complicated for not much benefit and in an already complicated system.
		return
	end

	-- An example of when this would be `true` is if the player starts mining a cube, moves their mouse away from it, and then moves it back on. During the time that the mouse was away, `can_mine` reported a specific fail message and the mining was paused.
	local unpaused = state.last_fail ~= nil
	if unpaused then
		mine_new_cube(state, cube_now)
		return
	end
	state.last_fail = nil

	if cube_now ~= state.cube_target then
		mine_new_cube(state, cube_now)
		return
	end

	local time_elapsed = os.clock() - state.time_start
	local time_fraction = math.min(1, time_elapsed / CUBE_MINE_TIME)
	-- See `TRANSPARENCY_MAXIMUM.luau` for an explanation of this operation.
	local transparency_fraction = time_fraction * TRANSPARENCY_MAXIMUM
	set_mining_display(state, transparency_fraction)

	if time_fraction >= 1 then
		local_mining_finished(state)
	end
end

function mine_start(cube: BasePart): ()
	local fail_message = can_mine(cube)
	local failed = fail_message ~= nil
	if failed == true then
		debug_print(`Failed to start mining: {fail_message}`)
		return
	end

	if local_mining ~= nil then
		debug_print("Error: A local mining is already active.")
		return
	end

	disable_heartbeat_passive()

	if connection_input == nil then
		activate_input_ended()
	end

	id += 1

	local cube_target: Part = cube :: any
	local connection_heartbeat = RunService.Heartbeat:Connect(on_heartbeat_active)
	local time_start = os.clock()

	debug_print("Activated active heartbeat.")

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

	table.insert(minings, state)

	local_mining = state

	ReplicatedStorage.remotes.mine_cube:FireServer(id, cube)
end

local function on_mine_suceeded(id: number): ()
	local state: state_pending? = find_by_id(id)
	if state == nil then
		return
	end

	local position = state.cube_target.Position
	-- Players can only place a cube in a previously occupied position after the cube is mined on the server.
	cube_cache[position] = nil
	cleanup_pending(state)
end

local function on_mine_failed(id: number): ()
	local state: state_pending? = find_by_id(id)
	if state == nil then
		return
	end

	set_mining_display(state, 0)
	state.cube_target.Parent = workspace
	debug_print("Server reported failure. Local cube was returned.")
	cleanup_pending(state)
end

ReplicatedStorage.remotes.mine_finished.OnClientEvent:Connect(on_mine_suceeded)
ReplicatedStorage.remotes.mine_failed.OnClientEvent:Connect(on_mine_failed)

return activate_heartbeat_passive
