const ReplicatedStorage = game:GetService("ReplicatedStorage")
const registry = require(ReplicatedStorage.shared.entity.registry)

type marked_entities = {
	[registry.entity]: {
		marked_by: registry.entity,
		last_marked: number,
	},
}

local marked_entities: marked_entities = {}

return marked_entities
