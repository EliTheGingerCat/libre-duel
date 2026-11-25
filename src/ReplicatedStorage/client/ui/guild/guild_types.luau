const ReplicatedStorage = game:GetService("ReplicatedStorage")

const guild_snapshot_types = require(ReplicatedStorage.shared.guild.guild_snapshot_types)
const player_row_types = require(script.Parent.Parent.player_row.player_row_types)
const profile_types = require(script.Parent.Parent.profile_card.profile_types)

export type member = player_row_types.player_summary & {
	joined: string,
	is_owner: boolean,
	stats: { profile_types.stat_group },
}

export type banned_member = player_row_types.player_summary & {
	banned: string,
}

export type incoming_invite = {
	guild_id: string,
	name: string,
	tag: string,
	icon: string,
	banner: string,
	inviter_username: string,
	member_count: number,
}

export type guild = {
	id: string,
	name: string,
	tag: string,
	icon: string,
	banner: string,
	info_fields: { profile_types.info_field },
	highlight_stats: { profile_types.highlight_stat },
	rank_history: { profile_types.rank_point },
	stat_sections: { profile_types.stat_section },
	about: string,
	members: { member },
	banned: { banned_member },
}

-- "create" and "incoming_invites" are what players without a guild see
export type page = "info" | "stats" | "members" | "invites" | "manage" | "create" | "incoming_invites"
-- another guild is read only, so only these are shown for it
export type viewed_page = "info" | "stats" | "members"

-- whoever is showing the menu owns the search and the invite list, the menu only displays them
export type invites = {
	outgoing: { player_row_types.player_summary },
	search_results: { player_row_types.player_summary },
	query: string,
	on_search: (query: string) -> (),
	on_invite: (player: player_row_types.player_summary) -> (),
	on_cancel: (player: player_row_types.player_summary) -> (),
}

export type member_action = "view_profile" | "kick" | "ban"
export type banned_member_action = "view_profile" | "unban"

-- everything the menu can ask for, whoever shows the menu talks to the server
-- these must not yield, the menu calls them straight from input events
export type actions = {
	on_create: (info: guild_snapshot_types.guild_info_input) -> (),
	on_leave: () -> (),
	on_delete: () -> (),
	on_rename: (name: string) -> (),
	on_edit_description: (description: string) -> (),
	-- the server asks for the new image in a popup
	on_change_icon: () -> (),
	on_change_banner: () -> (),
	on_member_action: (action: member_action, member: member) -> (),
	on_banned_member_action: (action: banned_member_action, banned_member: banned_member) -> (),
	on_accept_invite: (invite: incoming_invite) -> (),
	on_decline_invite: (invite: incoming_invite) -> (),
	on_view_guild_info: (invite: incoming_invite) -> (),
	on_block_guild: (invite: incoming_invite) -> (),
	-- switches tabs while another guild is showing
	on_select_viewed_page: (page: viewed_page) -> (),
}

return {}
