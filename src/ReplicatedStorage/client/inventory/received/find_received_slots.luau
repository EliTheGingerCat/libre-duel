const ReplicatedStorage = game:GetService("ReplicatedStorage")

const inventory_types = require(ReplicatedStorage.shared.inventory.inventory_types)

-- a slot counts as received when it gained an item it didn't have, or more of the item it had
const function find_received_slots(previous: inventory_types.inventory, current: inventory_types.inventory): { number }
	local received_slots: { number } = {}
	for slot_index, current_slot in current do
		if type(current_slot) ~= "table" then
			continue
		end
		const previous_slot = previous[slot_index]
		if type(previous_slot) ~= "table" or previous_slot.item_id ~= current_slot.item_id then
			table.insert(received_slots, slot_index)
		elseif current_slot.amount > previous_slot.amount then
			table.insert(received_slots, slot_index)
		end
	end
	return received_slots
end

return find_received_slots
