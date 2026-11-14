const ReplicatedStorage = game:GetService("ReplicatedStorage")

const registry = require(ReplicatedStorage.shared.entity.registry)

const function get_living_humanoid(entity: registry.entity): Humanoid?
	const character = registry.get_character(entity)
	const humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
	return if humanoid ~= nil and humanoid.Health > 0 then humanoid else nil
end

return get_living_humanoid
