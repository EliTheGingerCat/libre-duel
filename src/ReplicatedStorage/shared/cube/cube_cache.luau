const CollectionService = game:GetService("CollectionService")

const CUBE_TAG = "cube"

const positions: { [Instance]: Vector3? } = {}
-- Counted, because the client's temporary cube overlaps the server's cube until it is destroyed.
const counts: { [Vector3]: number? } = {}

local function track(cube: Instance): ()
	if positions[cube] ~= nil or not cube:IsA("BasePart") then
		return
	end
	const position = cube.Position
	positions[cube] = position
	counts[position] = (counts[position] or 0) + 1
end

local function untrack(cube: Instance): ()
	const position = positions[cube]
	if position == nil then
		return
	end
	positions[cube] = nil
	const count = (counts[position] or 0) - 1
	counts[position] = if count > 0 then count else nil
end

local function is_occupied(position: Vector3): boolean
	return counts[position] ~= nil
end

-- Following the tag means every way a cube can leave the world frees its position.
CollectionService:GetInstanceAddedSignal(CUBE_TAG):Connect(track)
CollectionService:GetInstanceRemovedSignal(CUBE_TAG):Connect(untrack)
for _, cube in CollectionService:GetTagged(CUBE_TAG) do
	track(cube)
end

return {
	is_occupied = is_occupied,
	track = track,
}
