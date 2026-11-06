-- entity -> selected hotbar slot
local ReplicatedStorage = game:GetService("ReplicatedStorage")

const registry = require(ReplicatedStorage.shared.entity.registry)

local entity_selected_slots: { [registry.entity]: number } = {}

return entity_selected_slots
