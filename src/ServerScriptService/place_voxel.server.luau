local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local voxel = ServerStorage.Voxel
local voxel_cache = require(ReplicatedStorage.modules.voxel_cache)
local get_player_position = require(ReplicatedStorage.modules.get_player_position)
local player_voxel_range_server = require(ServerScriptService.modules.player_voxel_range_server)
local snap_coordinate = require(ReplicatedStorage.modules.snap_coordinate)
local play_sound_excluding = require(ServerScriptService.modules.play_sound_excluding)

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

local function on_invoke(player: Player, voxel_position: unknown): string?
	if typeof(voxel_position) ~= "Vector3" then
		return "Invalid arguments."
	end

	local player_position = get_player_position(player)
	if player_position == nil then
		return "Player has no position."
	end

	local distance = (voxel_position - player_position).Magnitude
	if distance > player_voxel_range_server then
		return "Too far."
	end

	if not verify_position(voxel_position) then
		return "Invalid position."
	end

	local occupied = voxel_cache[voxel_position]
	if occupied then
		return "Occupied."
	end

	voxel_cache[voxel_position] = true

	local clone = voxel:Clone()
	clone.Position = voxel_position
	clone.Parent = workspace
	play_sound_excluding(player, "voxel_placed", voxel_position)

	return
end

ReplicatedStorage.remotes.place_voxel.OnServerInvoke = on_invoke
