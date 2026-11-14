const VIEWMODEL_CONSTANTS = {
	offset = CFrame.new(0.15, -0.1, -0.20),
	item_rotation = CFrame.Angles(0, math.rad(90), 0),

	swing_pose = CFrame.new(-0.03, -0.02, -0.04) * CFrame.Angles(math.rad(-60), 0, 0),
	-- Time is one way, so a full swing takes twice this because the tween reverses
	swing_tween_info = TweenInfo.new(0.13, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true),

	block_pose = CFrame.new(-0.06, 0.01, 0.02) * CFrame.Angles(math.rad(90), math.rad(150), math.rad(250)),

	cube_size = 0.08,

	bow_full_draw_seconds = 2, -- matches when a shot reaches full damage in bow_handler

	eat_pose = CFrame.new(-0.1, 0.02, 0.03) * CFrame.Angles(0, math.rad(90), 0),
	eat_bob_height = 0.008,
	eat_bob_speed = 24,
	eat_smoothing = 12,

	bob_full_speed = 32,
	bob_radians_per_stud = 0.6,
	bob_sideways = 0.01,
	bob_vertical = 0.006,
	bob_smoothing = 10,
}

return VIEWMODEL_CONSTANTS
