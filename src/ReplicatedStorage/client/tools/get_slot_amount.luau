const ReplicatedStorage = game:GetService("ReplicatedStorage")

const client_inventory_util = require(ReplicatedStorage.client.inventory.client_inventory_util)
const get_inventory_amount = require(script.Parent.get_inventory_amount)

-- nil while the slot is empty or the inventory hasn't arrived
const function get_slot_amount(slot: number): number?
	return get_inventory_amount(client_inventory_util.get_inventory(), slot)
end

return get_slot_amount
