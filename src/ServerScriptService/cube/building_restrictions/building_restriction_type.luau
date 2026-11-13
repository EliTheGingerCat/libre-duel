export type restriction_types = "building_banned_everywhere" | "only_in_build_zones" | "building_allowed_everywhere"

local building_restriction_type: { current: restriction_types } = {
	current = "only_in_build_zones",
}

return building_restriction_type
