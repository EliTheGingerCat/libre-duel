const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const ENTITY_RANGE = require(ReplicatedStorage.shared.combat.ENTITY_RANGE)
const EYE_OFFSET = require(ReplicatedStorage.shared.aim.EYE_OFFSET)
const get_entity_position = require(ReplicatedStorage.shared.entity.get_entity_position)

const local_player = Players.LocalPlayer

-- nil means the cube can be mined
-- reach is measured from the eyes to the aimed point, the same way the server checks it
const function get_mining_fail_reason(cube: Instance?, aim_position: Vector3): string?
	if cube == nil then
		return "Mouse is not pointing at anything."
	end

	if not cube:IsA("Part") then
		return "Mouse target is not a Part."
	end

	if cube:HasTag("cube") == false then
		return "Mouse target is not a cube."
	end

	const local_position = get_entity_position(local_player)
	if local_position == nil then
		return "Local position is missing."
	end

	const distance = (aim_position - (local_position + EYE_OFFSET)).Magnitude
	if distance > ENTITY_RANGE then
		return "Too far."
	end

	return nil
end

return get_mining_fail_reason
