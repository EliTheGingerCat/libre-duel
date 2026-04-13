local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")

local create_cube = require(ReplicatedStorage.shared.cube.create_cube)
local cube_cache = require(ReplicatedStorage.shared.cube.cube_cache)
local cube_in_hitbox = require(ReplicatedStorage.shared.cube.cube_in_hitbox)
local cube_size = require(ReplicatedStorage.shared.cube.cube_size)
local debug_print = require(script.Parent.Parent.util.debug_print)
local get_player_position = require(ReplicatedStorage.shared.player.get_player_position)
local player_range = require(ReplicatedStorage.shared.combat.player_range)
local secure_remote = require(ReplicatedStorage.client.cryptography.secure_remote)
local snap_coordinate = require(ReplicatedStorage.shared.cube.snap_coordinate)

local local_player = Players.LocalPlayer
local local_mouse = local_player:GetMouse()

local cube_size_half = cube_size / 2
local cube_size_half_soft = cube_size_half * 0.9

-- Create params once
local build_ray_params = RaycastParams.new()
build_ray_params.FilterType = Enum.RaycastFilterType.Exclude

local function snap_position(position: Vector3): Vector3
	return Vector3.new(
		snap_coordinate(position.X),
		snap_coordinate(position.Y),
		snap_coordinate(position.Z)
	)
end

local function place_cube(): ()
	local ignore_list = {local_player.Character}
	local overhang = workspace:FindFirstChild("sneak_overhang")
	if overhang then
		table.insert(ignore_list, overhang)
	end
	build_ray_params.FilterDescendantsInstances = ignore_list

	local mouse_ray = local_mouse.UnitRay
	local ray_result = workspace:Raycast(mouse_ray.Origin, mouse_ray.Direction * 1000, build_ray_params)

	if not ray_result then
		debug_print("Mouse target is missing.")
		return
	end

	local local_position = get_player_position(local_player)
	if local_position == nil then
		debug_print("Local position is missing.")
		return
	end

	local hit_position = ray_result.Position
	local distance = (hit_position - local_position).Magnitude

	if distance > player_range then
		debug_print("Too far.")
		return
	end

	local offset = ray_result.Normal * cube_size_half_soft
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

	local success: boolean = secure_remote.invoke_server_encrypted(ReplicatedStorage.remotes.place_cube, snapped)

	cube_temporary:Destroy()

	if success then
		cube_cache[snapped] = true
	end
end

return place_cube
