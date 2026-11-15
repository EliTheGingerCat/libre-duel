const ReplicatedStorage = game:GetService("ReplicatedStorage")

const ENTITY_RANGE = require(ReplicatedStorage.shared.combat.ENTITY_RANGE)

-- how far the aim ray's origin can be from the player's eyes, enough for a zoomed out camera
const MAXIMUM_ORIGIN_OFFSET = 16

const AIM_VALIDATION_CONSTANTS = {
	maximum_origin_offset = MAXIMUM_ORIGIN_OFFSET,
	-- nothing past this along the aim ray can be in reach, even from a zoomed out camera
	maximum_ray_distance = MAXIMUM_ORIGIN_OFFSET + ENTITY_RANGE * 2,
	-- the player's own position on the server trails their click by up to a chrono tick
	reach_tolerance = 1.5,
	-- an origin this close to the eyes is a first person camera, so the aim ray already proves line of sight
	-- and a second check from the slightly stale eye position would only cause false rejections
	first_person_origin_distance = 3,
}

return AIM_VALIDATION_CONSTANTS
