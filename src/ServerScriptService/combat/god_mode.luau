const ReplicatedStorage = game:GetService("ReplicatedStorage")

const registry = require(ReplicatedStorage.shared.entity.registry)

-- keyed by entity rather than character, so it survives respawns
const god_entities: { [registry.entity]: true? } = {}

local god_mode = {}

function god_mode.is_god(entity: registry.entity): boolean
	return god_entities[entity] == true
end

function god_mode.set_god(entity: registry.entity, enabled: boolean): ()
	god_entities[entity] = if enabled then true else nil
end

const function on_entity_removed(entity: registry.entity): ()
	god_entities[entity] = nil
end

registry.removed:Connect(on_entity_removed)

return god_mode
