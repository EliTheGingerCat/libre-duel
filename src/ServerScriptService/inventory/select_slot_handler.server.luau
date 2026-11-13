const ReplicatedStorage = game:GetService("ReplicatedStorage")

const inventory_util = require(script.Parent.inventory_util)
const registry = require(ReplicatedStorage.shared.entity.registry)

const select_slot = ReplicatedStorage.remotes.select_slot

const function on_select_slot(player: Player, slot: unknown): ()
	if type(slot) ~= "number" or not inventory_util.is_hotbar_slot(slot) then
		return
	end
	inventory_util.set_selected_slot(player, slot)
end

const function on_entity_removed(entity: registry.entity): ()
	inventory_util.clear_selected_slot(entity)
end

select_slot.OnServerEvent:Connect(on_select_slot)
registry.removed:Connect(on_entity_removed)
