const ReplicatedStorage = game:GetService("ReplicatedStorage")

const INVENTORY_CONSTANTS = require(ReplicatedStorage.shared.inventory.INVENTORY_CONSTANTS)

-- steps through the hotbar and wraps around at either end
const function get_cycled_slot(slot_current: number, step: number): number
	return (slot_current - 1 + step) % INVENTORY_CONSTANTS.COLUMNS + 1
end

return get_cycled_slot
