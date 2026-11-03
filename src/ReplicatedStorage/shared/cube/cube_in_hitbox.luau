const CollectionService = game:GetService("CollectionService")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const CUBE_SIZE = require(script.Parent.CUBE_SIZE)
const registry = require(ReplicatedStorage.shared.entity.registry)

local function cube_in_hitbox(position: Vector3, ignore_entity: registry.entity?): boolean
	const ignore_character = if ignore_entity ~= nil then registry.get_character(ignore_entity) else nil
	const parts = workspace:GetPartBoundsInBox(CFrame.new(position), Vector3.new(CUBE_SIZE, CUBE_SIZE, CUBE_SIZE))

	for _, part in parts do
		if CollectionService:HasTag(part, "cube_hitbox") then
			if ignore_character ~= nil and part:IsDescendantOf(ignore_character) then
				continue
			end
			return true
		end
	end

	return false
end

return cube_in_hitbox
