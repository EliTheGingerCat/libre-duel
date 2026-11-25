const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const inventory_types = require(ReplicatedStorage.shared.inventory.inventory_types)
const zap_server_network = require(ServerScriptService.network.zap_server_network)

-- zap can't send the "empty" string next to slot tables, see network_inventory_slot in network.zap
const function encode_network_inventory(inventory: inventory_types.inventory?): zap_server_network.network_inventory?
	if inventory == nil then
		return nil
	end
	const network_inventory: zap_server_network.network_inventory = {}
	for slot_index, slot in ipairs(inventory) do
		if type(slot) == "string" then
			network_inventory[slot_index] = { kind = "empty" }
		else
			network_inventory[slot_index] = {
				kind = "item",
				item_id = slot.item_id,
				amount = slot.amount,
				data = slot.data,
			}
		end
	end
	return network_inventory
end

return encode_network_inventory
