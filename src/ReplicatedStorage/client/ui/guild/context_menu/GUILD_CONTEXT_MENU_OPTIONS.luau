const ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const guild_context_menu_types = require(script.Parent.guild_context_menu_types)

type option = guild_context_menu_types.option

const WHITE = Color3.new(1, 1, 1)
const VIEW_PROFILE: option = { id = "view_profile", text = "View profile", colour = WHITE }

const GUILD_CONTEXT_MENU_OPTIONS = {
	member_for_owner = {
		VIEW_PROFILE,
		{ id = "kick", text = "Kick", colour = COLOURS.danger_text, needs_confirmation = true },
		{ id = "ban", text = "Ban", colour = COLOURS.danger_text, needs_confirmation = true },
	} :: { option },
	member_for_member = { VIEW_PROFILE } :: { option },
	banned_member = {
		VIEW_PROFILE,
		{ id = "unban", text = "Unban", colour = COLOURS.green_300 },
	} :: { option },
	incoming_invite = {
		{ id = "view_guild_info", text = "View guild info", colour = WHITE },
		{ id = "block_guild", text = "Block guild", colour = COLOURS.danger_text },
	} :: { option },
}

return GUILD_CONTEXT_MENU_OPTIONS
