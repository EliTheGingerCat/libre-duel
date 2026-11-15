const ReplicatedStorage = game:GetService("ReplicatedStorage")

const AIM_VALIDATION_CONSTANTS = require(script.Parent.AIM_VALIDATION_CONSTANTS)
const ENTITY_RANGE = require(ReplicatedStorage.shared.combat.ENTITY_RANGE)
const validate_aim_ray = require(script.Parent.validate_aim_ray)

-- how far the position is from the player's eyes, and whether that's close enough to interact with
const function get_reach(aim: validate_aim_ray.validated_aim, position: Vector3): (number, boolean)
	const reach = (position - aim.eye_position).Magnitude
	return reach, reach <= ENTITY_RANGE + AIM_VALIDATION_CONSTANTS.reach_tolerance
end

return get_reach
