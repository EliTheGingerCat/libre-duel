const registry = require(script.Parent.registry)

local function get_entity_position(entity: registry.entity): Vector3?
	const character = registry.get_character(entity)
	if character == nil then
		return nil
	end
	const root = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
	if root and root:IsA("BasePart") then
		return root.Position
	end
	return nil
end

return get_entity_position
