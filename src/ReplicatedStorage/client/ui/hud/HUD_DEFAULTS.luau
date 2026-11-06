-- Where each HUD widget starts before the player moves it in the editor.
-- stack_offset is multiplied by the widget's viewport scale and added to its Y offset, so it clears scaled neighbours.
-- hidden widgets start off the screen, as if removed, until added from the selector.
const HUD_DEFAULTS = {
	ComboCounter = { size = Vector2.new(168, 42), anchor = Vector2.new(1, 0), position = UDim2.new(1, -12, 0, 12) },
	FpsCounter = {
		size = Vector2.new(168, 42),
		anchor = Vector2.new(1, 0),
		position = UDim2.new(1, -12, 0, 12),
		stack_offset = 102,
	},
	Hotbar = { anchor = Vector2.new(0.5, 1), position = UDim2.new(0.5, 0, 1, -20) },
	Infoboard = { anchor = Vector2.new(0.5, 0), position = UDim2.new(0.5, 0, 0, 10) },
	Keystrokes = {
		size = Vector2.new(152, 137),
		anchor = Vector2.one,
		position = UDim2.new(1, -12, 1, -12),
		stack_offset = -166,
		hidden = true,
	},
	Mousestrokes = {
		size = Vector2.new(224, 158),
		anchor = Vector2.one,
		position = UDim2.new(1, -12, 1, -12),
		hidden = true,
	},
	Notifications = { anchor = Vector2.new(0, 1), position = UDim2.new(0, 15, 1, -15) },
	Paperdoll = { size = Vector2.new(128, 210), anchor = Vector2.new(0, 1), position = UDim2.new(0, 12, 1, -12) },
	PlayButton = { anchor = Vector2.new(0.5, 1), position = UDim2.new(0.5, 0, 1, -32), stack_offset = -130 },
	QueueStatus = { anchor = Vector2.new(0.5, 1), position = UDim2.new(0.5, 0, 1, -32), stack_offset = -130 },
	ReachCounter = {
		size = Vector2.new(168, 42),
		anchor = Vector2.new(1, 0),
		position = UDim2.new(1, -12, 0, 12),
		stack_offset = 51,
	},
	Tablist = { anchor = Vector2.new(0.5, 0), position = UDim2.new(0.5, 0, 0, 147) },
}

return table.freeze(HUD_DEFAULTS)
