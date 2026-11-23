const profile_types = require(script.Parent.Parent.profile_card.profile_types)

export type player_profile = {
	user_id: number,
	display_name: string,
	username: string,
	headshot: string,
	banner: string,
	info_fields: { profile_types.info_field },
	highlight_stats: { profile_types.highlight_stat },
	rank_history: { profile_types.rank_point },
	bio: string,
	stat_sections: { profile_types.stat_section },
}

export type page = "info" | "stats"

-- everything the menu can ask for, whoever shows the menu talks to the server
-- these must not yield, the menu calls them straight from input events
export type actions = {
	-- the server asks for the new image in a popup
	on_change_banner: () -> (),
	on_edit_bio: (bio: string) -> (),
	-- the server asks for the reason in a popup
	on_report: () -> (),
}

return {}
