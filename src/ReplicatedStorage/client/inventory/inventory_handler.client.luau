const ReplicatedStorage = game:GetService("ReplicatedStorage")

const client_inventory_util = require(script.Parent.client_inventory_util)
const inventory_types = require(ReplicatedStorage.shared.inventory.inventory_types)
const remote_id = require(script.Parent.remote_id)

const update_inventory = ReplicatedStorage.remotes.update_inventory

local function on_update(update: inventory_types.inventory_update): ()
	-- server pushes have no id, request responses are only applied if they're for the latest request
	if update.id ~= nil and update.id ~= remote_id.current then
		return
	end
	client_inventory_util.set_inventory(update.inventory)
end

update_inventory.OnClientEvent:Connect(on_update)
