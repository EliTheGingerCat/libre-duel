const PhysicsService = game:GetService("PhysicsService")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const registry = require(ReplicatedStorage.shared.entity.registry)

const GROUP_CHARACTER = "character"
const GROUP_HITBOX = "hitbox"

PhysicsService:RegisterCollisionGroup(GROUP_CHARACTER)
PhysicsService:RegisterCollisionGroup(GROUP_HITBOX)
PhysicsService:CollisionGroupSetCollidable(GROUP_HITBOX, GROUP_CHARACTER, false)
PhysicsService:CollisionGroupSetCollidable(GROUP_HITBOX, GROUP_HITBOX, true)
PhysicsService:CollisionGroupSetCollidable(GROUP_HITBOX, "Default", true)

const connections: { [registry.entity]: RBXScriptConnection } = {}

local function set_collision_group(descendant: Instance): ()
	if descendant:IsA("BasePart") then
		descendant.CollisionGroup = if descendant.Name == GROUP_HITBOX then GROUP_HITBOX else GROUP_CHARACTER
	end
end

local function on_entity_removed(entity: registry.entity): ()
	const connection = connections[entity]
	if connection then
		connection:Disconnect()
		connections[entity] = nil
	end
end

local function on_character_added(character: Model, entity: registry.entity): ()
	on_entity_removed(entity)
	connections[entity] = character.DescendantAdded:Connect(set_collision_group)
	for _, descendant in character:GetDescendants() do
		set_collision_group(descendant)
	end
end

registry.character_added:Connect(on_character_added)
registry.removed:Connect(on_entity_removed)
for _, entity in registry.get_all() do
	const character = registry.get_character(entity)
	if character then
		on_character_added(character, entity)
	end
end
