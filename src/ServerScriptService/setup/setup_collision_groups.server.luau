local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")

-- 1. Create Groups
const GROUP_CHARACTER = "character"
const GROUP_HITBOX = "hitbox"

PhysicsService:RegisterCollisionGroup(GROUP_CHARACTER)
PhysicsService:RegisterCollisionGroup(GROUP_HITBOX)

-- 2. Set Rules
-- "hitbox" (the ray) should pass through "character" (the limbs)
PhysicsService:CollisionGroupSetCollidable(GROUP_HITBOX, GROUP_CHARACTER, false)
-- "hitbox" (the ray) should hit "hitbox" (the target)
PhysicsService:CollisionGroupSetCollidable(GROUP_HITBOX, GROUP_HITBOX, true)
-- "hitbox" (the ray) should hit "Default" (walls/floor)
PhysicsService:CollisionGroupSetCollidable(GROUP_HITBOX, "Default", true)

-- 3. Apply Groups (Robustly)
local function set_collision_group(part: BasePart)
	if part.Name == "hitbox" then
		part.CollisionGroup = GROUP_HITBOX
	else
		part.CollisionGroup = GROUP_CHARACTER
	end
end

local function on_character_added(character: Model)
	-- Handle parts already there
	for _, descendant in character:GetDescendants() do
		if descendant:IsA("BasePart") then
			set_collision_group(descendant)
		end
	end

	-- Handle parts that load later (Limbs, Accessories, Meshes)
	character.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("BasePart") then
			set_collision_group(descendant)
		end
	end)
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(on_character_added)
	if player.Character then
		on_character_added(player.Character)
	end
end)
