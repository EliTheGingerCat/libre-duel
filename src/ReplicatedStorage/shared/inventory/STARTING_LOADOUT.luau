const ReplicatedStorage = game:GetService("ReplicatedStorage")

const tool_registry = require(ReplicatedStorage.shared.tools.registry)
const inventory_logic = require(script.Parent.inventory_logic)

const STARTING_LOADOUT: { [number]: string } = {

}

for slot, id in STARTING_LOADOUT do
	assert(inventory_logic.is_valid_slot(slot), `Loadout slot {slot} is out of range.`)
	assert(tool_registry.get(id) ~= nil, `Loadout slot {slot} holds unregistered tool "{id}".`)
end

return table.freeze(STARTING_LOADOUT)
