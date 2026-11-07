local ReplicatedStorage = game:GetService("ReplicatedStorage")

const registry = require(ReplicatedStorage.shared.entity.registry)

type blocking_entities = { registry.entity }

local blocking_entities = {}

return blocking_entities
