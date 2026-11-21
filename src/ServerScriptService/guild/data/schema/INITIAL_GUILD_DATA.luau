const ReplicatedStorage = game:GetService("ReplicatedStorage")

const GAME_STATS = require(ReplicatedStorage.shared.modes.GAME_STATS)

export type guild_member = {
	joined: number,
	-- copied from the player's data whenever they join a server, so offline members still show it
	banner: string,
	playtime: number,
	-- only stats earned while in this guild, reset when they leave
	stats: GAME_STATS.modes,
}

export type rank_point = { time: number, rank: number }

-- the shape saves had before any migrations, new fields go in a migration instead of here
-- member stats and totals get missing modes filled in by normalize_mode_stats, so new modes need no migration
const INITIAL_GUILD_DATA = {
	id = "" :: string, -- a GUID, never changes, also the datastore key
	owner_id = 0 :: number,
	created = 0 :: number,
	-- deleted guilds keep their record so stale player hints resolve to "not a member"
	deleted = false :: boolean,

	name = "" :: string,
	tag = "" :: string,
	description = "" :: string,
	icon = "" :: string, -- "rbxassetid://{number}"
	banner = "" :: string, -- "rbxassetid://{number}"
	discord_invite = "" :: string,

	members = {} :: { [string]: guild_member }, -- tostring(userid)
	outgoing_invites = {} :: { [string]: number }, -- tostring(userid) -> unix time
	banned = {} :: { [string]: number }, -- tostring(userid) -> unix time

	-- keeps what departed members earned, so the guild never loses wins when someone leaves
	totals = {} :: GAME_STATS.modes,
	total_playtime = 0 :: number,
	rank_history = {} :: { rank_point },
}

export type guild_data = typeof(INITIAL_GUILD_DATA)

return INITIAL_GUILD_DATA
