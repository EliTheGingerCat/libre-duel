local CollectionService = game:GetService("CollectionService")

const CUBE_SIZE = require(script.Parent.CUBE_SIZE)

local function cube_in_hitbox(position: Vector3, ignore_player: Player?): boolean
	local parts = workspace:GetPartBoundsInBox(CFrame.new(position), Vector3.new(CUBE_SIZE, CUBE_SIZE, CUBE_SIZE))

	for _, part in parts do
		if CollectionService:HasTag(part, "cube_hitbox") then
			if ignore_player ~= nil and part:IsDescendantOf(ignore_player.Character) then
				continue
			end
			return true
		end
	end

	return false
end

return cube_in_hitbox
