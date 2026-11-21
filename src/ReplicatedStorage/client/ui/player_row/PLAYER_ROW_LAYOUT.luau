-- shared by every banner row and the member header so their columns line up
const PLAYER_ROW_LAYOUT = {
	height = 64,
	padding = 12,
	headshot_gap = 10,
	column_width = 0.33,
	action_size = 32,
	action_inset = 20,
	corner_radius = 24,
	background = Color3.fromRGB(30, 30, 30),
	banner_fade = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(0.176, 0.481),
		NumberSequenceKeypoint.new(0.367, 0.788),
		NumberSequenceKeypoint.new(1, 1),
	}),
}

return PLAYER_ROW_LAYOUT
