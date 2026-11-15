const MELEE_SWING_CONSTANTS = {
	-- how far the aim ray's origin can be from the attacker's root, enough for a zoomed out camera
	maximum_origin_offset = 16,
	-- reach is measured from here, not from the camera, so moving the camera can't extend it
	eye_offset = Vector3.new(0, 1.5, 0),
	-- the attacker's own position on the server trails their swing by up to a chrono tick
	reach_tolerance = 1.5,
	maximum_render_time_entries = 32,
}

return MELEE_SWING_CONSTANTS
