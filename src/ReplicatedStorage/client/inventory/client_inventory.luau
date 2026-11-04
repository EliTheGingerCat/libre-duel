-- tostring(UserId) -> slot -> item (1d array). local player's entry is nil until the server sends it
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const inventory_types = require(ReplicatedStorage.shared.inventory.inventory_types)

local client_inventory: inventory_types.player_inventories = {}

return client_inventory
