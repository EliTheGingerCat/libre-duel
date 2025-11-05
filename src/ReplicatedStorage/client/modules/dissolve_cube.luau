local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local cube_cache = require(ReplicatedStorage.modules.cube_cache)
local debug_print = require(script.Parent.debug_print)
local get_player_position = require(ReplicatedStorage.modules.get_player_position)
local player_range = require(ReplicatedStorage.modules.player_range)

local local_player = Players.LocalPlayer
local local_mouse = local_player:GetMouse()

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

	cube.Parent = nil

	local success: true? = ReplicatedStorage.remotes.dissolve_cube:InvokeServer(cube)

	if success == true then
		local position = cube.Position
		-- Players can only place a cube in a previously occupied position after the server verifies it. (This line of code is after the asynchronous invocation.)
		cube_cache[position] = nil
	else
		cube.Parent = workspace
		debug_print("Server reported failure. Local cube was returned.")
	end
end

return dissolve_cube
