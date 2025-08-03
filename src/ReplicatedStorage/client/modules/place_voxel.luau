local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local voxel_cache = require(ReplicatedStorage.modules.voxel_cache)
local voxel_size = require(ReplicatedStorage.modules.voxel_size)
local get_player_position = require(ReplicatedStorage.modules.get_player_position)
local player_voxel_range = require(ReplicatedStorage.modules.player_voxel_range)
local play_sound_local = require(script.Parent.play_sound_local)
local snap_coordinate = require(ReplicatedStorage.modules.snap_coordinate)

local local_player = Players.LocalPlayer
local local_mouse = local_player:GetMouse()

local voxel_size_half = voxel_size / 2
local voxel_size_half_soft = voxel_size_half * 0.9
local pos = voxel_size_half_soft
local neg = voxel_size_half_soft * -1
-- This is a slightly bad solution but I can not think of anything else.
local surface_offset = {
	[Enum.NormalId.Left]   = Vector3.new(neg, 0),
	[Enum.NormalId.Right]  = Vector3.new(pos, 0),
	[Enum.NormalId.Bottom] = Vector3.new(0, neg, 0),
	[Enum.NormalId.Top]    = Vector3.new(0, pos, 0),
	[Enum.NormalId.Back]   = Vector3.new(0, 0, pos),
	[Enum.NormalId.Front]  = Vector3.new(0, 0, neg)
} :: {[Enum.NormalId]: Vector3}

local function snap_position(position: Vector3): Vector3
	return Vector3.new(
		snap_coordinate(position.X),
		snap_coordinate(position.Y),
		snap_coordinate(position.Z)
	)
end

local function place_voxel(): ()
	if local_mouse.Target == nil then
		return
	end

	local local_position = get_player_position(local_player)
	if local_position == nil then
		return
	end

	local hit_position = local_mouse.Hit.Position

	local distance = (hit_position - local_position).Magnitude
	if distance > player_voxel_range then
		return
	end

	local offset = surface_offset[local_mouse.TargetSurface]
	local snapped = snap_position(hit_position + offset)

	local occupied = voxel_cache[snapped]
	if occupied then
		return
	end

	play_sound_local("voxel_placed", snapped)

	local error_message: string? = ReplicatedStorage.remotes.place_voxel:InvokeServer(snapped)

	if error_message == nil then
		voxel_cache[snapped] = true
	else
		print(`Failed to place voxel. Reason: {error_message}`)
	end
end

return place_voxel
