-- first person constants
return table.freeze({
	-- studs per gl unit of the hand projection, small so the item stays inside the camera and out of walls
	unit = 0.2 / 0.72,
	-- the hand is always drawn with a 70 degree projection no matter the fov setting
	reference_fov = 70,
	ticks_per_second = 20,
	swing_duration_ticks = 6,
	eat_duration_ticks = 32,
	-- the equip progress moves at most this much per tick
	equip_speed = 0.4,
	-- the rendered arm pitch and yaw follow the camera by this fraction per tick
	arm_follow = 0.5,
	arm_sway = 0.1,
})
