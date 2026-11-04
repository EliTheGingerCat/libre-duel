-- player -> slot -> item (1d array)
local ReplicatedStorage = game:GetService("ReplicatedStorage")

const inventory_types = require(ReplicatedStorage.shared.inventory.inventory_types)

local player_inventories: inventory_types.player_inventories = {}

return player_inventories
