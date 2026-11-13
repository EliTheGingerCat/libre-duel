local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")

local create_cube = require(ReplicatedStorage.shared.cube.create_cube)
local cube_cache = require(ReplicatedStorage.shared.cube.cube_cache)
local cube_in_hitbox = require(ReplicatedStorage.shared.cube.cube_in_hitbox)
const get_aim_ray = require(ReplicatedStorage.client.aim.get_aim_ray)
const CUBE_SIZE = require(ReplicatedStorage.shared.cube.CUBE_SIZE)
local debug_print = require(ReplicatedStorage.client.util.debug_print)
const ENTITY_RANGE = require(ReplicatedStorage.shared.combat.ENTITY_RANGE)
local get_entity_position = require(ReplicatedStorage.shared.entity.get_entity_position)
local snap_coordinate = require(ReplicatedStorage.shared.cube.snap_coordinate)
local tool_types = require(ReplicatedStorage.shared.tools.tool_types)

local local_player = Players.LocalPlayer

const CUBE_SIZE_HALF = CUBE_SIZE / 2
const CUBE_SIZE_HALF_SOFT = CUBE_SIZE_HALF * 0.9

-- Create params once
local build_ray_params = RaycastParams.new()
build_ray_params.FilterType = Enum.RaycastFilterType.Exclude

const function snap_position(position: Vector3): Vector3
	return Vector3.new(snap_coordinate(position.X), snap_coordinate(position.Y), snap_coordinate(position.Z))
end

const function place_cube(tool: tool_types.tool): ()
	local ignore_list = { local_player.Character }
	local overhang = workspace:FindFirstChild("sneak_overhang")
	if overhang then
		table.insert(ignore_list, overhang)
	end
	build_ray_params.FilterDescendantsInstances = ignore_list

	const aim_ray = get_aim_ray()
	local ray_result = workspace:Raycast(aim_ray.Origin, aim_ray.Direction * 1000, build_ray_params)

	if not ray_result then
		debug_print("Mouse target is missing.")
		return
	end

	local local_position = get_entity_position(local_player)
	if local_position == nil then
		debug_print("Local position is missing.")
		return
	end

	local hit_position = ray_result.Position
	local distance = (hit_position - local_position).Magnitude

	if distance > ENTITY_RANGE then
		debug_print("Too far.")
		return
	end

	local offset = ray_result.Normal * CUBE_SIZE_HALF_SOFT
	local snapped = snap_position(hit_position + offset)

	if cube_cache.is_occupied(snapped) then
		debug_print("Occupied by cube.")
		return
	end

	local occupied_entity = cube_in_hitbox(snapped)
	if occupied_entity then
		debug_print("Occupied by entity.")
		return
	end

	local cube_temporary = create_cube(tool.behaviours.cube or {})
	cube_temporary.Position = snapped
	cube_temporary.Parent = workspace.runtime_instances.cubes

	ReplicatedStorage.remotes.place_cube:InvokeServer(snapped)

	cube_temporary:Destroy()
end

return place_cube
