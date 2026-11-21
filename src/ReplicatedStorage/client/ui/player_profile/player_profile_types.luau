const profile_types = require(script.Parent.Parent.profile_card.profile_types)

export type player_profile = {
	display_name: string,
	username: string,
	headshot: string,
	banner: string,
	info_fields: { profile_types.info_field },
	highlight_stats: { profile_types.highlight_stat },
	rank_history: { profile_types.rank_point },
	bio: string,
	stats: { profile_types.stat_group },
}

return {}
