const ReplicatedStorage = game:GetService("ReplicatedStorage")

const inventory_types = require(ReplicatedStorage.shared.inventory.inventory_types)
const tool_types = require(ReplicatedStorage.shared.tools.tool_types)
const zap_client_network = require(ReplicatedStorage.client.network.zap_client_network)

-- turns the slots back into what the rest of the game uses, see network_inventory_slot in network.zap
const function decode_network_inventory(
	network_inventory: zap_client_network.network_inventory?
): inventory_types.inventory?
	if network_inventory == nil then
		return nil
	end
	const inventory: inventory_types.inventory = {}
	for slot_index, network_slot in network_inventory do
		if network_slot.kind == "empty" then
			inventory[slot_index] = "empty"
		else
			inventory[slot_index] = {
				item_id = network_slot.item_id,
				amount = network_slot.amount,
				-- the server only ever puts tool overrides in here
				data = network_slot.data :: tool_types.overrides?,
			}
		end
	end
	return inventory
end

return decode_network_inventory
