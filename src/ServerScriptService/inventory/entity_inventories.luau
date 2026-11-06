-- entity -> slot -> item (1d array)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

const inventory_types = require(ReplicatedStorage.shared.inventory.inventory_types)

local entity_inventories: inventory_types.entity_inventories = {}

return entity_inventories
