const ServerScriptService = game:GetService("ServerScriptService")

const AIM_VALIDATION_CONSTANTS = require(script.Parent.AIM_VALIDATION_CONSTANTS)
const debug_print = require(ServerScriptService.util.debug_print)
const get_eye_position = require(script.Parent.get_eye_position)

export type validated_aim = {
	origin: Vector3,
	direction: Vector3,
	eye_position: Vector3,
	character: Model,
}

const function is_finite_vector(vector: Vector3): boolean
	const sum = vector.X + vector.Y + vector.Z
	return sum == sum and math.abs(sum) ~= math.huge
end

-- the client only sends where its camera aimed, which is checked against the server's copy of the player
-- direction comes back as a unit vector
const function validate_aim_ray(player: Player, origin: unknown, direction: unknown): validated_aim?
	if typeof(origin) ~= "Vector3" or typeof(direction) ~= "Vector3" then
		debug_print("Aim ray has the wrong types.")
		return nil
	end
	if not is_finite_vector(origin) or not is_finite_vector(direction) or direction.Magnitude < 1e-3 then
		debug_print("Aim ray is not finite.")
		return nil
	end

	const character = player.Character
	const eye_position = get_eye_position(player)
	if character == nil or eye_position == nil then
		debug_print("Aiming player has no root.")
		return nil
	end

	const origin_offset = (origin - eye_position).Magnitude
	if origin_offset > AIM_VALIDATION_CONSTANTS.maximum_origin_offset then
		debug_print("Aim origin too far from the player:", origin_offset)
		return nil
	end

	return {
		origin = origin,
		direction = direction.Unit,
		eye_position = eye_position,
		character = character,
	}
end

return validate_aim_ray
