-- the client half of looking into the inventory of another player, sessions are started by the server

const ReplicatedStorage = game:GetService("ReplicatedStorage")

const client_inventory = require(script.Parent.Parent.client_inventory)
const INVENTORY_ACTIONS = require(ReplicatedStorage.shared.inventory.INVENTORY_ACTIONS)
const inventory_types = require(ReplicatedStorage.shared.inventory.inventory_types)
const invsee_state = require(script.Parent.invsee_state)

const invsee = ReplicatedStorage.remotes.invsee

local invsee_util = {}

function invsee_util.get_target(): Player?
	return invsee_state.target
end

function invsee_util.get_inventory(): inventory_types.inventory?
	const target = invsee_state.target
	return if target ~= nil then client_inventory[target] else nil
end

function invsee_util.apply_update(update: inventory_types.invsee_update): ()
	const previous_target = invsee_state.target
	const target = update.target
	if target == nil and previous_target == nil then
		return
	end
	if target ~= previous_target then
		-- nothing sent during the previous session matters anymore
		invsee_state.settled_id = invsee_state.request_id
	elseif update.id ~= nil then
		-- answers are only applied if they're for the latest request
		if update.id ~= invsee_state.request_id then
			return
		end
		invsee_state.settled_id = update.id
	elseif invsee_state.settled_id ~= invsee_state.request_id then
		-- a push that is older than the answer on its way, applying it would undo the prediction for a moment
		return
	end

	if previous_target then
		client_inventory[previous_target] = nil
	end
	invsee_state.target = target
	if target and update.inventory then
		client_inventory[target] = update.inventory
	elseif target then
		client_inventory[target] = nil
	end
	invsee_state.on_change:Fire()
end

function invsee_util.stop(): ()
	if invsee_state.target == nil then
		return
	end
	const request: inventory_types.invsee_request = { action = "stop" }
	invsee:FireServer(request)
	invsee_util.apply_update({})
end

-- predicts the action locally, the server answers with the authoritative inventory
const function request_action(
	action: inventory_types.inventory_action,
	from_slot_index: number,
	to_slot_index: number
): boolean
	const target = invsee_state.target
	const inventory = invsee_util.get_inventory()
	if target == nil or inventory == nil or not INVENTORY_ACTIONS[action](inventory, from_slot_index, to_slot_index) then
		return false
	end
	invsee_state.request_id += 1
	const request: inventory_types.invsee_request = {
		action = action,
		target = target,
		from = from_slot_index,
		to = to_slot_index,
		id = invsee_state.request_id,
	}
	invsee:FireServer(request)
	invsee_state.on_change:Fire()
	return true
end

function invsee_util.swap_items(slot_1_index: number, slot_2_index: number): boolean
	return request_action("swap_items", slot_1_index, slot_2_index)
end

function invsee_util.quick_move(slot_index: number): boolean
	return request_action("quick_move", slot_index, slot_index)
end

return invsee_util
