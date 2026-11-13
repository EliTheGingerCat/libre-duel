const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const ENTITY_RANGE = require(ReplicatedStorage.shared.combat.ENTITY_RANGE)
const get_entity_position = require(ReplicatedStorage.shared.entity.get_entity_position)
const get_mouse_target = require(script.Parent.get_mouse_target)
const registry = require(ReplicatedStorage.shared.entity.registry)

const local_player = Players.LocalPlayer

export type melee_target = {
	entity: registry.entity,
	distance: number,
}

-- the entity under the crosshair if it's in reach, otherwise the reason it isn't
const function get_melee_target(): (melee_target?, string?)
	const target_hitbox: BasePart? = get_mouse_target()
	if target_hitbox == nil then
		return nil, "Mouse target is missing."
	end

	const local_position = get_entity_position(local_player)
	if local_position == nil then
		return nil, "Local position is missing."
	end

	const target_root_container = target_hitbox.Parent
	const target_character = if target_root_container then target_root_container.Parent else nil
	if target_character == nil then
		return nil, "Mouse target's character is missing."
	end

	if not target_character:IsA("Model") then
		return nil, "Mouse target's parent is not a Model."
	end

	const target_root = target_character:FindFirstChild("HumanoidRootPart")
	if target_root == nil or not target_root:IsA("BasePart") then
		return nil, "Humanoid root part is missing."
	end

	const distance = (target_root.CFrame.Position - (local_position + Vector3.new(0, 3, 0))).Magnitude
	if distance > ENTITY_RANGE then
		return nil, "Too far."
	end

	const entity = registry.from_character(target_character)
	if entity == nil then
		return nil, "Mouse target is not an entity."
	end

	return { entity = entity, distance = distance }, nil
end

return get_melee_target
