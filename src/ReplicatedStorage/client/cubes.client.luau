local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local cube_cache = require(ReplicatedStorage.modules.cube_cache)
local cube_size = require(ReplicatedStorage.modules.cube_size)
local get_player_position = require(ReplicatedStorage.modules.get_player_position)
local player_range = require(ReplicatedStorage.modules.player_range)
local snap_coordinate = require(ReplicatedStorage.modules.snap_coordinate)

local local_player = Players.LocalPlayer
local local_mouse = local_player:GetMouse()

local cube_size_half = cube_size / 2
local cube_size_half_soft = cube_size_half * 0.9
local pos = cube_size_half_soft
local neg = cube_size_half_soft * -1
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

local function on_input_began(input: InputObject): ()
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
		return
	end

	if local_mouse.Target == nil then
		return
	end

	local local_position = get_player_position(local_player)
	if local_position == nil then
		return
	end

	local hit_position = local_mouse.Hit.Position

	local distance = (hit_position - local_position).Magnitude
	if distance > player_range then
		return
	end

	local offset = surface_offset[local_mouse.TargetSurface]
	local snapped = snap_position(hit_position + offset)

	local occupied = cube_cache[snapped]
	if occupied then
		return
	end

	local error_message: string? = ReplicatedStorage.remotes.place_cube:InvokeServer(snapped)

	if error_message == nil then
		cube_cache[snapped] = true
	else
		print(`Failed to place block. Reason: {error_message}`)
	end
end

UserInputService.InputBegan:Connect(on_input_began)