-- jump, movement and camera are left to the stock ControlModule and CameraModule (A, left stick, right stick)
-- R3 is taken by the stock camera zoom, Select by gamepad UI navigation and Start by the Roblox menu, so none are used here
const GAMEPAD_KEYBINDS = {
	inventory = Enum.KeyCode.ButtonY,
	menu_close = Enum.KeyCode.ButtonB,
	player_sneak = Enum.KeyCode.ButtonB,
	play = Enum.KeyCode.DPadUp,
	slot_next = Enum.KeyCode.ButtonR1,
	slot_previous = Enum.KeyCode.ButtonL1,
	tablist = Enum.KeyCode.ButtonX,
	tool_attack = Enum.KeyCode.ButtonR2,
	tool_use = Enum.KeyCode.ButtonL2,
}

return GAMEPAD_KEYBINDS
