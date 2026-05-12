local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local entity_mod = require(ReplicatedStorage.shared.entity)
local debug_print = require(ServerScriptService.util.debug_print)
local hitbox = ServerStorage.hitbox
local cube_hitbox = ServerStorage.cube_hitbox

type entity = entity_mod.entity

local function attach_part(template: BasePart, root: BasePart): ()
	local clone = template:Clone()
	local weld = clone.Weld
	weld.Part0 = clone
	weld.Part1 = root
	clone.Parent = root
end

local function on_character_added(character: Model): ()
	local root = character:FindFirstChild("HumanoidRootPart") :: Part?
	if root == nil then
		debug_print("Humanoid root part is missing.")
		return
	end

	attach_part(hitbox, root)
	attach_part(cube_hitbox, root)
end

local function on_new_entity(entity: entity): ()
	if entity.player ~= nil then
		local player = entity.player
		if player.Character ~= nil then
			on_character_added(player.Character)
		end

		player.CharacterAdded:Connect(on_character_added)
	end

	if entity.character ~= nil then
		-- is not player
		on_character_added(entity.character)
	end
end

for _, entity in entity_mod.all_entities do
	on_new_entity(entity)
end

entity_mod.on_new_entity:Connect(on_new_entity)
