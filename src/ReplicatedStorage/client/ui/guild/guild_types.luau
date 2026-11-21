const player_row_types = require(script.Parent.Parent.player_row.player_row_types)
const profile_types = require(script.Parent.Parent.profile_card.profile_types)

export type member = player_row_types.player_summary & {
	joined: string,
	is_owner: boolean,
	stats: { profile_types.stat_group },
}

export type guild = {
	name: string,
	tag: string,
	icon: string,
	banner: string,
	info_fields: { profile_types.info_field },
	highlight_stats: { profile_types.highlight_stat },
	rank_history: { profile_types.rank_point },
	about: string,
	members: { member },
}

export type page = "info" | "members" | "invites" | "manage"

-- whoever is showing the menu owns the search and the invite list, the menu only displays them
export type invites = {
	outgoing: { player_row_types.player_summary },
	search_results: { player_row_types.player_summary },
	query: string,
	on_search: (query: string) -> (),
	on_invite: (player: player_row_types.player_summary) -> (),
	on_cancel: (player: player_row_types.player_summary) -> (),
}

return {}
