const ReplicatedStorage = game:GetService("ReplicatedStorage")

const client_inventory_util = require(script.Parent.client_inventory_util)
const inventory_types = require(ReplicatedStorage.shared.inventory.inventory_types)
const item_received = require(script.Parent.received.item_received)
const remote_id = require(script.Parent.remote_id)

const update_inventory = ReplicatedStorage.remotes.update_inventory

const function on_update(update: inventory_types.inventory_update): ()
	-- server pushes have no id, request responses are only applied if they're for the latest request
	if update.id ~= nil and update.id ~= remote_id.current then
		return
	end
	const previous_inventory = client_inventory_util.get_inventory()
	client_inventory_util.set_inventory(update.inventory)
	-- only server pushes can hand out items, responses just confirm what the player did
	if update.id == nil then
		item_received.compare(previous_inventory, update.inventory)
	end
end

update_inventory.OnClientEvent:Connect(on_update)
