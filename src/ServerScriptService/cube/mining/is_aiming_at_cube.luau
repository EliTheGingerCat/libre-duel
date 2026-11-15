const ServerScriptService = game:GetService("ServerScriptService")
const Workspace = game:GetService("Workspace")

const AIM_VALIDATION_CONSTANTS = require(ServerScriptService.aim_validation.AIM_VALIDATION_CONSTANTS)
const debug_print = require(ServerScriptService.util.debug_print)
const get_reach = require(ServerScriptService.aim_validation.get_reach)
const is_aim_line_of_sight_clear = require(ServerScriptService.aim_validation.is_aim_line_of_sight_clear)
const validate_aim_ray = require(ServerScriptService.aim_validation.validate_aim_ray)

-- how far out from the face the eye check aims, so it doesn't count the face it's aiming at as a wall
const FACE_CLEARANCE = 0.1

const mining_ray_parameters = RaycastParams.new()
mining_ray_parameters.FilterType = Enum.RaycastFilterType.Exclude

-- the client says which cube it's mining so both sides agree on it, the server checks the aim really lands on it first
const function is_aiming_at_cube(aim: validate_aim_ray.validated_aim, cube: BasePart): boolean
	mining_ray_parameters.FilterDescendantsInstances = { aim.character }
	const ray_result = Workspace:Raycast(
		aim.origin,
		aim.direction * AIM_VALIDATION_CONSTANTS.maximum_ray_distance,
		mining_ray_parameters
	)
	if ray_result == nil or ray_result.Instance ~= cube then
		debug_print("Mining ray doesn't hit that cube.")
		return false
	end

	const reach, is_in_reach = get_reach(aim.eye_position, ray_result.Position)
	if not is_in_reach then
		debug_print("Too far:", reach)
		return false
	end

	if not is_aim_line_of_sight_clear(aim, ray_result.Position + ray_result.Normal * FACE_CLEARANCE) then
		debug_print("Mined face is behind a wall.")
		return false
	end

	return true
end

return is_aiming_at_cube
