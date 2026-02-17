local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")

-- 1. Create Groups
local group_character = "character"
local group_hitbox = "hitbox"

PhysicsService:RegisterCollisionGroup(group_character)
PhysicsService:RegisterCollisionGroup(group_hitbox)

-- 2. Set Rules
-- "hitbox" (the ray) should pass through "character" (the limbs)
PhysicsService:CollisionGroupSetCollidable(group_hitbox, group_character, false)
-- "hitbox" (the ray) should hit "hitbox" (the target)
PhysicsService:CollisionGroupSetCollidable(group_hitbox, group_hitbox, true)
-- "hitbox" (the ray) should hit "Default" (walls/floor)
PhysicsService:CollisionGroupSetCollidable(group_hitbox, "Default", true)

-- 3. Apply Groups (Robustly)
local function set_collision_group(part: BasePart)
	if part.Name == "hitbox" then
		part.CollisionGroup = group_hitbox
	else
		part.CollisionGroup = group_character
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
