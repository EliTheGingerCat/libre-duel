const AIM_VALIDATION_CONSTANTS = require(script.Parent.AIM_VALIDATION_CONSTANTS)
const is_line_of_sight_clear = require(script.Parent.is_line_of_sight_clear)
const validate_aim_ray = require(script.Parent.validate_aim_ray)

-- the camera has to see the target, and a zoomed out camera also needs the eyes to see it,
-- otherwise an origin placed on the far side of a wall would get around it
const function is_aim_line_of_sight_clear(aim: validate_aim_ray.validated_aim, target_position: Vector3): boolean
	if not is_line_of_sight_clear(aim.origin, target_position) then
		return false
	end
	const origin_offset = (aim.origin - aim.eye_position).Magnitude
	if origin_offset <= AIM_VALIDATION_CONSTANTS.first_person_origin_distance then
		return true
	end
	return is_line_of_sight_clear(aim.eye_position, target_position)
end

return is_aim_line_of_sight_clear
