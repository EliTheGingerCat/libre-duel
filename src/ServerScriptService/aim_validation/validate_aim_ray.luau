const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const AIM_VALIDATION_CONSTANTS = require(script.Parent.AIM_VALIDATION_CONSTANTS)
const chrono = require(ReplicatedStorage.Packages.chrono)
const debug_print = require(ServerScriptService.util.debug_print)
const EYE_OFFSET = require(ReplicatedStorage.shared.aim.EYE_OFFSET)

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

-- chrono's latest snapshot is what the client last reported, while the root part on the server
-- trails it by native replication's own delay, which adds up fast when running and jumping
const function get_freshest_root_position(player: Player, root: BasePart): Vector3
	const entity = chrono.Holder.GetEntityFromPlayer(player)
	const latest_cframe = if entity then entity.latestCFrame else nil
	return if latest_cframe then latest_cframe.Position else root.Position
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
	const root = if character then character:FindFirstChild("HumanoidRootPart") else nil
	if character == nil or root == nil or not root:IsA("BasePart") then
		debug_print("Aiming player has no root.")
		return nil
	end

	const eye_position = get_freshest_root_position(player, root) + EYE_OFFSET
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
