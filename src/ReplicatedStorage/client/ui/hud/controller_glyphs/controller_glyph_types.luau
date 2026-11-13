export type controller_glyph_row = {
	label: string,
	key_codes: { Enum.KeyCode },
}

-- what the player can do right now, already boiled down to the labels that should show
export type controller_glyph_context = {
	-- closable menus take B to close, the rest (like the hud editor) have their own controls
	menu: "closable" | "other" | nil,
	play_available: boolean,
	attack_label: string?,
	use_label: string?,
	sneak_relevant: boolean,
	hotbar_relevant: boolean,
}

return {}
