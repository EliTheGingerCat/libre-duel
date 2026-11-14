const ReplicatedStorage = game:GetService("ReplicatedStorage")

const inventory_types = require(ReplicatedStorage.shared.inventory.inventory_types)

-- nil while the slot is empty or there is no inventory
const function get_inventory_amount(inventory: inventory_types.inventory?, slot: number): number?
	if inventory == nil then
		return nil
	end
	const item = inventory[slot]
	return if type(item) == "table" then item.amount else nil
end

return get_inventory_amount
