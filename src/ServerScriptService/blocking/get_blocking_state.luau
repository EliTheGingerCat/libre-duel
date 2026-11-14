const blocking_entities = require(script.Parent.blocking_entities)
const inventory_util = require(script.Parent.Parent.inventory.inventory_util)

-- checks the held tool here rather than asserting on slot switches, because the client
-- legitimately sends the new slot just before it sends the unblock
const function get_blocking_state(player): boolean
	if blocking_entities[player] and inventory_util.has_behaviour(player, "sword") then
		return true
	end
	return false
end

return get_blocking_state
