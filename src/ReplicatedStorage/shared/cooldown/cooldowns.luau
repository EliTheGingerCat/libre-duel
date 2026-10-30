const ReplicatedStorage = game:GetService("ReplicatedStorage")

const registry = require(ReplicatedStorage.shared.entity.registry)

export type entity_cooldowns = {
	[string]: number,
}

const cooldowns: { [registry.entity]: entity_cooldowns } = {}

local function on_entity_removed(entity: registry.entity): ()
	cooldowns[entity] = nil
end

registry.removed:Connect(on_entity_removed)

return cooldowns
