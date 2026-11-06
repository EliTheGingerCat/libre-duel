-- Inventory given on spawn. Each slot holds a tool id from `ReplicatedStorage.shared.tools.registry`.
-- Slots 1 to COLUMNS are the hotbar.
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const tool_registry = require(ReplicatedStorage.shared.tools.registry)
const inventory_logic = require(script.Parent.inventory_logic)

const STARTING_LOADOUT: { [number]: string } = {
	[1] = "sword",
	[2] = "cube",
	[3] = "pickaxe",
	[4] = "bow",
	[5] = "cake",
	[9] = "mode_selector",
}

for slot, id in STARTING_LOADOUT do
	assert(inventory_logic.is_valid_slot(slot), `Loadout slot {slot} is out of range.`)
	assert(tool_registry.get(id) ~= nil, `Loadout slot {slot} holds unregistered tool "{id}".`)
end

return table.freeze(STARTING_LOADOUT)
