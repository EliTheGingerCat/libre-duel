const ReplicatedStorage = game:GetService("ReplicatedStorage")

const decode_network_inventory = require(ReplicatedStorage.client.inventory.decode_network_inventory)
const invsee_util = require(script.Parent.invsee_util)
const zap_client_network = require(ReplicatedStorage.client.network.zap_client_network)

const function on_update(update: { target: Player?, inventory: zap_client_network.network_inventory?, id: number? }): ()
	invsee_util.apply_update({
		target = update.target,
		inventory = decode_network_inventory(update.inventory),
		id = update.id,
	})
end

zap_client_network.update_invsee.set_callback(on_update)
