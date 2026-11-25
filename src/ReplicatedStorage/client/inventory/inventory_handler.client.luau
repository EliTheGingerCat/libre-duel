const ReplicatedStorage = game:GetService("ReplicatedStorage")

const client_inventory_util = require(script.Parent.client_inventory_util)
const decode_network_inventory = require(script.Parent.decode_network_inventory)
const item_received = require(script.Parent.received.item_received)
const remote_id = require(script.Parent.remote_id)
const zap_client_network = require(ReplicatedStorage.client.network.zap_client_network)

const function on_update(update: { inventory: zap_client_network.network_inventory?, id: number? }): ()
	-- server pushes have no id, request responses are only applied if they're for the latest request
	if update.id ~= nil and update.id ~= remote_id.current then
		return
	end
	const previous_inventory = client_inventory_util.get_inventory()
	const inventory = decode_network_inventory(update.inventory)
	client_inventory_util.set_inventory(inventory)
	-- only server pushes can hand out items, responses just confirm what the player did
	if update.id == nil then
		item_received.compare(previous_inventory, inventory)
	end
end

zap_client_network.update_inventory.set_callback(on_update)
