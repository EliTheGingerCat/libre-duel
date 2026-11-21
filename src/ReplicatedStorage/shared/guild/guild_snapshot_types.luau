const ReplicatedStorage = game:GetService("ReplicatedStorage")

const GAME_STATS = require(ReplicatedStorage.shared.modes.GAME_STATS)

-- what the server replicates, raw ids and numbers so the client decides how to show them

export type member_snapshot = {
	user_id: number,
	joined: number,
	banner: string,
	playtime: number,
	stats: GAME_STATS.modes,
}

export type banned_snapshot = {
	user_id: number,
	banned_at: number,
}

export type outgoing_invite_snapshot = {
	user_id: number,
	invited_at: number,
}

export type rank_point_snapshot = { time: number, rank: number }

export type guild_snapshot = {
	id: string,
	owner_id: number,
	created: number,
	name: string,
	tag: string,
	description: string,
	icon: string,
	banner: string,
	discord_invite: string,
	members: { member_snapshot },
	banned: { banned_snapshot },
	outgoing_invites: { outgoing_invite_snapshot },
	totals: GAME_STATS.modes,
	total_playtime: number,
	-- nil when the guild is outside the tracked ranks
	rank: number?,
	rank_history: { rank_point_snapshot },
}

export type incoming_invite_snapshot = {
	guild_id: string,
	guild_name: string,
	guild_tag: string,
	guild_icon: string,
	guild_banner: string,
	member_count: number,
	inviter_id: number,
	invited_at: number,
}

export type player_search_result = {
	user_id: number,
	username: string,
	display_name: string,
}

export type guild_info_input = {
	name: string,
	tag: string,
	description: string,
	icon: string,
	banner: string,
	discord_invite: string,
}

return {}
