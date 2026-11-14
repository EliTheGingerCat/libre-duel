const ReplicatedStorage = game:GetService("ReplicatedStorage")

const find_received_slots = require(script.Parent.find_received_slots)
const inventory_types = require(ReplicatedStorage.shared.inventory.inventory_types)
const signal = require(ReplicatedStorage.Packages.signal)

local item_received = {
	-- fires with the slot index for every slot that got items from a server push
	on_receive = signal.new(),
}

-- a missing previous inventory means a fresh spawn, which isn't receiving anything
function item_received.compare(previous: inventory_types.inventory?, current: inventory_types.inventory?): ()
	if previous == nil or current == nil then
		return
	end
	for _, slot_index in find_received_slots(previous, current) do
		item_received.on_receive:Fire(slot_index)
	end
end

return item_received
