const CollectionService = game:GetService("CollectionService")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const building_restriction_type = require(script.Parent.building_restriction_type)
const CUBE_SIZE = require(ReplicatedStorage.shared.cube.CUBE_SIZE)

const ZONE_TAG = "build_zone"
const CUBE_SIZE_HALF = CUBE_SIZE / 2
-- Absorbs any float errors
const EPSILON = 1e-3

const zones: { [BasePart]: true? } = {}

const function track(zone: Instance): ()
	if zone:IsA("BasePart") then
		zones[zone] = true
	end
end

const function untrack(zone: Instance): ()
	if zone:IsA("BasePart") then
		zones[zone] = nil
	end
end

-- The whole cube has to fit inside a zone, not just touch it.
const function is_in_build_zone(position: Vector3): boolean
	for zone in zones do
		const local_position = zone.CFrame:PointToObjectSpace(position)
		const half = zone.Size / 2
		if
			math.abs(local_position.X) + CUBE_SIZE_HALF <= half.X + EPSILON
			and math.abs(local_position.Y) + CUBE_SIZE_HALF <= half.Y + EPSILON
			and math.abs(local_position.Z) + CUBE_SIZE_HALF <= half.Z + EPSILON
		then
			return true
		end
	end
	return false
end

const function is_building_allowed(position: Vector3): boolean
	const restriction = building_restriction_type.current
	if restriction == "building_allowed_everywhere" then
		return true
	elseif restriction == "building_banned_everywhere" then
		return false
	end
	return is_in_build_zone(position)
end

CollectionService:GetInstanceAddedSignal(ZONE_TAG):Connect(track)
CollectionService:GetInstanceRemovedSignal(ZONE_TAG):Connect(untrack)
for _, zone in CollectionService:GetTagged(ZONE_TAG) do
	track(zone)
end

return is_building_allowed
