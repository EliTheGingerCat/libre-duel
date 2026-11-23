const ReplicatedStorage = game:GetService("ReplicatedStorage")

const GAME_STATS = require(ReplicatedStorage.shared.modes.GAME_STATS)

-- what the server sends for a profile, raw ids and numbers so the client decides how to show them

export type rank_point_snapshot = { time: number, rank: number }

export type profile_guild_snapshot = {
	id: string,
	name: string,
	tag: string,
}

export type player_profile_snapshot = {
	user_id: number,
	first_joined: number,
	last_online: number,
	banner: string,
	bio: string,
	playtime: number,
	stats: GAME_STATS.modes,
	-- nil when the player is outside the tracked ranks
	rank: number?,
	rank_history: { rank_point_snapshot },
	-- nil when the player isn't in a guild
	guild: profile_guild_snapshot?,
}

return {}
