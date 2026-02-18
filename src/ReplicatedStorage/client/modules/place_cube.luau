local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local create_cube = require(ReplicatedStorage.modules.create_cube)
local cube_cache = require(ReplicatedStorage.modules.cube_cache)
local cube_in_hitbox = require(ReplicatedStorage.modules.cube_in_hitbox)
local cube_size = require(ReplicatedStorage.modules.cube_size)
local debug_print = require(script.Parent.debug_print)
local get_player_position = require(ReplicatedStorage.modules.get_player_position)
local player_range = require(ReplicatedStorage.modules.player_range)
local snap_coordinate = require(ReplicatedStorage.modules.snap_coordinate)

local local_player = Players.LocalPlayer
local local_mouse = local_player:GetMouse()

local cube_size_half = cube_size / 2
local cube_size_half_soft = cube_size_half * 0.9
local pos = cube_size_half_soft
local neg = cube_size_half_soft * -1

local function snap_position(position: Vector3): Vector3
	return Vector3.new(
		snap_coordinate(position.X),
		snap_coordinate(position.Y),
		snap_coordinate(position.Z)
	)
end

local function place_cube(): ()
	if local_mouse.Target == nil then
		debug_print("Mouse target is missing.")
		return
	end

	local local_position = get_player_position(local_player)
	if local_position == nil then
		debug_print("Local position is missing.")
		return
	end

	local hit_position = local_mouse.Hit.Position

	local distance = (hit_position - local_position).Magnitude
	if distance > player_range then
		debug_print("Too far.")
		return
	end

	local offset = Vector3.FromNormalId(local_mouse.TargetSurface) * cube_size_half_soft
	local snapped = snap_position(hit_position + offset)

	local occupied_cube = cube_cache[snapped]
	if occupied_cube then
		debug_print("Occupied by cube.")
		return
	end

	local occupied_player = cube_in_hitbox(snapped)
	if occupied_player then
		debug_print("Occupied by player.")
		return
	end

	local cube_temporary = create_cube()
	cube_temporary.Position = snapped
	cube_temporary.Parent = workspace

	local success: boolean = ReplicatedStorage.remotes.place_cube:InvokeServer(snapped)

	-- Whether the server accepts or rejects the cube, this local one is no longer necessary.
	cube_temporary:Destroy()

	if success then
		cube_cache[snapped] = true
	end
end

return place_cube
