const ReplicatedStorage = game:GetService("ReplicatedStorage")

const inventory_util = require(script.Parent.inventory_util)
const registry = require(ReplicatedStorage.shared.entity.registry)

const function on_character_added(_character: Model, entity: registry.entity): ()
	const inventory = inventory_util.generate_inventory(entity)
	if type(inventory) == "table" then
		inventory_util.give_loadout(inventory)
		inventory_util.created:Fire(entity, inventory)
		-- remote events queue until the client connects, so this arrives even if the client script loads late
		inventory_util.replicate(entity)
	end
end

const function on_entity_died(_character: Model, entity: registry.entity): ()
	if inventory_util.delete_inventory(entity) then
		inventory_util.replicate(entity)
	end
end

-- entities removed while alive never fire died
const function on_entity_removed(entity: registry.entity): ()
	inventory_util.delete_inventory(entity)
end

registry.character_added:Connect(on_character_added)
registry.died:Connect(on_entity_died)
registry.removed:Connect(on_entity_removed)

for _, entity in registry.get_all() do
	const character = registry.get_character(entity)
	if character then
		on_character_added(character, entity)
	end
end
