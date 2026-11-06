const ReplicatedStorage = game:GetService("ReplicatedStorage")

const inventory_util = require(script.Parent.inventory_util)
const registry = require(ReplicatedStorage.shared.entity.registry)

local function on_character_added(character: Model, entity: registry.entity): ()
	const inventory = inventory_util.generate_inventory(entity)
	if type(inventory) == "table" then
		inventory_util.give_loadout(inventory)
		inventory_util.created:Fire(entity, inventory)
		-- remote events queue until the client connects, so this arrives even if the client script loads late
		inventory_util.replicate(entity)
	end

	local function on_died(): ()
		-- a replacement bot can reuse the ID while its old character is still around
		if registry.get_character(entity) == character and inventory_util.delete_inventory(entity) then
			inventory_util.replicate(entity)
		end
	end

	const humanoid = character:WaitForChild("Humanoid") :: Humanoid
	-- the connection gets cleaned up when the character is destroyed
	humanoid.Died:Once(on_died)
end

-- entities removed while alive never fire Died
local function on_entity_removed(entity: registry.entity): ()
	inventory_util.delete_inventory(entity)
end

registry.character_added:Connect(on_character_added)
registry.removed:Connect(on_entity_removed)

for _, entity in registry.get_all() do
	const character = registry.get_character(entity)
	if character then
		on_character_added(character, entity)
	end
end
