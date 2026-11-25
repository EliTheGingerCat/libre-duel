const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const inventory_logic = require(ReplicatedStorage.shared.inventory.inventory_logic)
const inventory_util = require(script.Parent.inventory_util)
const registry = require(ReplicatedStorage.shared.entity.registry)
const zap_server_network = require(ServerScriptService.network.zap_server_network)

const function on_select_slot(player: Player, slot: number): ()
	if not inventory_logic.is_hotbar_slot(slot) then
		return
	end
	inventory_util.set_selected_slot(player, slot)
end

const function on_entity_removed(entity: registry.entity): ()
	inventory_util.clear_selected_slot(entity)
end

zap_server_network.select_slot.set_callback(on_select_slot)
registry.removed:Connect(on_entity_removed)
