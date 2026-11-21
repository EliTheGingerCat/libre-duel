const PLACEHOLDER_ASSETS = require(script.Parent.PLACEHOLDER_ASSETS)
const player_row_types = require(script.Parent.Parent.player_row.player_row_types)

const function create_candidate(
	user_id: number,
	display_name: string,
	username: string
): player_row_types.player_summary
	return {
		user_id = user_id,
		display_name = display_name,
		username = username,
		headshot = PLACEHOLDER_ASSETS.headshot,
		banner = PLACEHOLDER_ASSETS.member_banner,
	}
end

const PLACEHOLDER_INVITE_CANDIDATES: { player_row_types.player_summary } = {
	create_candidate(10, "NOT miau", "breter98"),
	create_candidate(11, "bread cat", "toast_enjoyer"),
	create_candidate(12, "a very long display name that will not fit", "longname"),
	create_candidate(13, "bridger", "bridge_main"),
}

return PLACEHOLDER_INVITE_CANDIDATES
