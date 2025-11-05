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

local local_player = Players.LocalPlayer
local local_mouse = local_player:GetMouse()

local connection_input: RBXScriptConnection?
local connection_target: RBXScriptConnection?
local cube_target: Part?
local time_start: number?

local function cleanup_cube(): ()
	assert(cube_target ~= nil, "There is no target.")
	cube_target = nil
end

local function cleanup_most(): ()
	if connection_input ~= nil then
		connection_input:Disconnect()
		connection_input = nil
	end

	if connection_target ~= nil then
		connection_target:Disconnect()
		connection_target = nil
	end
end

local function cleanup_all(): ()
	cleanup_most()
	cleanup_cube()
end

local function set_dissolution_display(fraction: number): ()
	assert(cube_target ~= nil, "There is no target.")
	cube_target.Transparency = fraction
end

local function dissolve_stop(): ()
	set_dissolution_display(0)
	cleanup_all()
	ReplicatedStorage.remotes.dissolve_stop:FireServer()
end

local function dissolution_finished(): ()
	assert(cube_target ~= nil, "There is no target.")
	cube_target.Parent = nil
	-- Cube pointer needs to stay until the server reports back.
	cleanup_most()
end

local function on_input_ended(input: InputObject): ()
	if input.UserInputType == keybinds.tool_use then
		debug_print("Keybind was released.")
		dissolve_stop()
	end
end

local function should_stop(): boolean
	local cube = local_mouse.Target
	if cube ~= cube_target then
		debug_print("Target changed.")
		return true
	end

	local local_position = get_player_position(local_player)
	if local_position == nil then
		debug_print("Local position is missing.")
		return true
	end

	local distance = (cube.Position - local_position).Magnitude
	if distance > player_range then
		debug_print("Too far.")
		return true
	end

	return false
end

local function on_heartbeat(): ()
	if should_stop() == true then
		dissolve_stop()
		return
	end

	assert(time_start ~= nil, "Time is missing.")
	assert(cube_target ~= nil, "Cube target is missing")
	
	local time_elapsed = tick() - time_start
	local time_fraction = math.min(1, time_elapsed / cube_dissolve_time)
	cube_target.Transparency = time_fraction

	if time_fraction >= 1 then
		dissolution_finished()
	end
end

local function dissolve_start(cube: Part): ()
	cube_target = cube
	connection_input = UserInputService.InputEnded:Connect(on_input_ended)
	connection_target = RunService.Heartbeat:Connect(on_heartbeat)
	time_start = tick()

	-- This connection is always made, even when debug mode is disabled.
	local function on_destroying(): ()
		debug_print("Destroying cube:", cube)
	end
	cube.Destroying:Connect(on_destroying)

	ReplicatedStorage.remotes.dissolve_cube:FireServer(cube)
end

local function on_dissolve_finished(): ()
	assert(cube_target ~= nil, "There is no target.")
	local position = cube_target.Position
	-- Players can only place a cube in a previously occupied position after the cube is dissolved on the server.
	cube_cache[position] = nil
	cleanup_all()
end

local function on_dissolve_failed(): ()
	assert(cube_target ~= nil, "There is no target.")
	set_dissolution_display(0)
	cube_target.Parent = workspace
	debug_print("Server reported failure. Local cube was returned.")
	cleanup_all()
end

ReplicatedStorage.remotes.dissolve_finished.OnClientEvent:Connect(on_dissolve_finished)
ReplicatedStorage.remotes.dissolve_failed.OnClientEvent:Connect(on_dissolve_failed)

local function dissolve_cube(): ()
	local cube = local_mouse.Target

	if cube == nil then
		debug_print("Mouse is not pointing at anything.")
		return
	end

	if not cube:IsA("Part") then
		debug_print("Mouse target is not a Part.")
		return
	end
	
	if cube:HasTag("cube") == false then
		debug_print("Mouse target is not a cube.")
		return
	end

	local local_position = get_player_position(local_player)
	if local_position == nil then
		debug_print("Local position is missing.")
		return
	end

	local distance = (cube.Position - local_position).Magnitude
	if distance > player_range then
		debug_print("Too far.")
		return
	end

	dissolve_start(cube)
end

return dissolve_cube
