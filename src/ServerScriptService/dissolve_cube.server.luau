local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local cube_cache = require(ReplicatedStorage.modules.cube_cache)
local debug_print = require(script.Parent.modules.debug_print)
local get_player_position = require(ReplicatedStorage.modules.get_player_position)
local player_range_server = require(ServerScriptService.modules.player_range_server)

local function on_invoke(player: Player, cube: unknown?): boolean?
	if cube == nil then
		debug_print("Not enough arguments.")
		return
	end
	
	if typeof(cube) ~= "Instance" then
		debug_print("Invalid arguments. Not an instance.")
		return
	end

	if not cube:IsA("Part") then
		debug_print("Invalid arguments. Not a Part.")
		return
	end

	if cube:HasTag("cube") == false then
		debug_print("Cube does not have the \"cube\" tag, so it is not actually a cube.")
		return
	end

	local player_position = get_player_position(player)
	if player_position == nil then
		debug_print("Player has no position.")
		return
	end

	local distance = (cube.Position - player_position).Magnitude
	if distance > player_range_server then
		debug_print("Too far.")
		return
	end

	cube:Destroy()
	cube_cache[cube.Position] = nil

	return true
end

ReplicatedStorage.remotes.dissolve_cube.OnServerInvoke = on_invoke
