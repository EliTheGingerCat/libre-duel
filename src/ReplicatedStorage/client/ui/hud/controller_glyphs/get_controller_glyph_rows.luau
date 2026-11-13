const ReplicatedStorage = game:GetService("ReplicatedStorage")

const GAMEPAD_KEYBINDS = require(ReplicatedStorage.client.util.GAMEPAD_KEYBINDS)
const controller_glyph_types = require(script.Parent.controller_glyph_types)

type controller_glyph_context = controller_glyph_types.controller_glyph_context
type controller_glyph_row = controller_glyph_types.controller_glyph_row

-- top to bottom, the most situational rows first so the always-there ones stay put against the bottom edge
const function get_controller_glyph_rows(context: controller_glyph_context): { controller_glyph_row }
	if context.menu == "closable" then
		return { { label = "Close", key_codes = { GAMEPAD_KEYBINDS.menu_close } } }
	elseif context.menu == "other" then
		return {}
	end

	const rows: { controller_glyph_row } = {}
	if context.play_available then
		table.insert(rows, { label = "Play", key_codes = { GAMEPAD_KEYBINDS.play } })
	end
	if context.attack_label ~= nil then
		table.insert(rows, { label = context.attack_label, key_codes = { GAMEPAD_KEYBINDS.tool_attack } })
	end
	if context.use_label ~= nil then
		table.insert(rows, { label = context.use_label, key_codes = { GAMEPAD_KEYBINDS.tool_use } })
	end
	if context.sneak_relevant then
		table.insert(rows, { label = "Sneak", key_codes = { GAMEPAD_KEYBINDS.player_sneak } })
	end
	if context.hotbar_relevant then
		table.insert(
			rows,
			{ label = "Hotbar", key_codes = { GAMEPAD_KEYBINDS.slot_previous, GAMEPAD_KEYBINDS.slot_next } }
		)
	end
	table.insert(rows, { label = "Inventory", key_codes = { GAMEPAD_KEYBINDS.inventory } })
	return rows
end

return get_controller_glyph_rows
