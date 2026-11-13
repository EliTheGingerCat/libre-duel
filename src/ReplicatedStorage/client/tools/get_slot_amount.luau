const ReplicatedStorage = game:GetService("ReplicatedStorage")

const client_inventory_util = require(ReplicatedStorage.client.inventory.client_inventory_util)

-- nil while the slot is empty or the inventory hasn't arrived
const function get_slot_amount(slot: number): number?
	const inventory = client_inventory_util.get_inventory()
	if inventory == nil then
		return nil
	end
	const item = inventory[slot]
	return if type(item) == "table" then item.amount else nil
end

return get_slot_amount
