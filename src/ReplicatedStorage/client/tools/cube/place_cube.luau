local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")

local create_cube = require(ReplicatedStorage.shared.cube.create_cube)
local cube_cache = require(ReplicatedStorage.shared.cube.cube_cache)
local cube_in_hitbox = require(ReplicatedStorage.shared.cube.cube_in_hitbox)
const get_aim_ray = require(ReplicatedStorage.client.aim.get_aim_ray)
const get_cube_placement_position = require(ReplicatedStorage.shared.cube.get_cube_placement_position)
local debug_print = require(ReplicatedStorage.client.util.debug_print)
const ENTITY_RANGE = require(ReplicatedStorage.shared.combat.ENTITY_RANGE)
const EYE_OFFSET = require(ReplicatedStorage.shared.aim.EYE_OFFSET)
local get_entity_position = require(ReplicatedStorage.shared.entity.get_entity_position)
local tool_types = require(ReplicatedStorage.shared.tools.tool_types)
const zap_client_network = require(ReplicatedStorage.client.network.zap_client_network)

local local_player = Players.LocalPlayer

-- Create params once
local build_ray_params = RaycastParams.new()
build_ray_params.FilterType = Enum.RaycastFilterType.Exclude

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
	local distance = (hit_position - (local_position + EYE_OFFSET)).Magnitude

	if distance > ENTITY_RANGE then
		debug_print("Too far.")
		return
	end

	-- only for the local checks and preview, the server casts the same aim and picks the cell itself
	local snapped = get_cube_placement_position(hit_position, ray_result.Normal)

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

	zap_client_network.place_cube.call(aim_ray.Origin, aim_ray.Direction)

	cube_temporary:Destroy()
end

return place_cube
