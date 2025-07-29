local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local cube = ServerStorage.Cube
local cube_cache = require(ReplicatedStorage.modules.cube_cache)
local get_player_position = require(ReplicatedStorage.modules.get_player_position)
local player_range_server = require(ServerScriptService.player_range_server)
local snap_coordinate = require(ReplicatedStorage.modules.snap_coordinate)

local function verify_coordinate(coordinate: number): boolean
	return coordinate == snap_coordinate(coordinate)
end

local function verify_position(position: Vector3): boolean
	return (
		    verify_coordinate(position.X)
		and verify_coordinate(position.Y)
		and verify_coordinate(position.Z)
	)
end

local function on_invoke(player: Player, cube_position: unknown): string?
	if typeof(cube_position) ~= "Vector3" then
		return "Invalid arguments."
	end

	local player_position = get_player_position(player)
	if player_position == nil then
		return "Player has no position."
	end

	local distance = (cube_position - player_position).Magnitude
	if distance > player_range_server then
		return "Too far."
	end

	if not verify_position(cube_position) then
		return "Invalid position."
	end

	local occupied = cube_cache[cube_position]
	if occupied then
		return "Occupied."
	end

	cube_cache[cube_position] = true

	local clone = cube:Clone()
	clone.Position = cube_position
	clone.Parent = workspace

	return
end

ReplicatedStorage.remotes.place_cube.OnServerInvoke = on_invoke