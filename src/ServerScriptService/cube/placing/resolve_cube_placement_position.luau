const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")
const Workspace = game:GetService("Workspace")

const AIM_VALIDATION_CONSTANTS = require(ServerScriptService.aim_validation.AIM_VALIDATION_CONSTANTS)
const debug_print = require(ServerScriptService.util.debug_print)
const get_cube_placement_position = require(ReplicatedStorage.shared.cube.get_cube_placement_position)
const get_reach = require(ServerScriptService.aim_validation.get_reach)
const is_aim_line_of_sight_clear = require(ServerScriptService.aim_validation.is_aim_line_of_sight_clear)
const registry = require(ReplicatedStorage.shared.entity.registry)
const validate_aim_ray = require(ServerScriptService.aim_validation.validate_aim_ray)

-- how far out from the face the eye check aims, so it doesn't count the face it's aiming at as a wall
const FACE_CLEARANCE = 0.1

const placement_ray_parameters = RaycastParams.new()
placement_ray_parameters.FilterType = Enum.RaycastFilterType.Exclude

const function is_part_of_character(instance: Instance): boolean
	const model = instance:FindFirstAncestorOfClass("Model")
	return model ~= nil and registry.from_character(model) ~= nil
end

-- the server casts the aim itself, so a cube always goes against a face the player can actually see
const function resolve_cube_placement_position(aim: validate_aim_ray.validated_aim): Vector3?
	placement_ray_parameters.FilterDescendantsInstances = { aim.character }
	const ray_result = Workspace:Raycast(
		aim.origin,
		aim.direction * AIM_VALIDATION_CONSTANTS.maximum_ray_distance,
		placement_ray_parameters
	)
	if ray_result == nil then
		debug_print("Placement ray hit nothing.")
		return nil
	end

	-- the client's ray stops on other players too, and a cube can't go inside them anyway
	if is_part_of_character(ray_result.Instance) then
		debug_print("Placement ray hit a character.")
		return nil
	end

	const reach, is_in_reach = get_reach(aim, ray_result.Position)
	if not is_in_reach then
		debug_print("Too far:", reach)
		return nil
	end

	if not is_aim_line_of_sight_clear(aim, ray_result.Position + ray_result.Normal * FACE_CLEARANCE) then
		debug_print("Placement face is behind a wall.")
		return nil
	end

	return get_cube_placement_position(ray_result.Position, ray_result.Normal)
end

return resolve_cube_placement_position
