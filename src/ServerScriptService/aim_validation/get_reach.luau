const ReplicatedStorage = game:GetService("ReplicatedStorage")

const AIM_VALIDATION_CONSTANTS = require(script.Parent.AIM_VALIDATION_CONSTANTS)
const ENTITY_RANGE = require(ReplicatedStorage.shared.combat.ENTITY_RANGE)

-- how far the position is from the eyes, and whether that's close enough to interact with
const function get_reach(eye_position: Vector3, position: Vector3): (number, boolean)
	const reach = (position - eye_position).Magnitude
	return reach, reach <= ENTITY_RANGE + AIM_VALIDATION_CONSTANTS.reach_tolerance
end

return get_reach
