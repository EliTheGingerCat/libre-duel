const ServerScriptService = game:GetService("ServerScriptService")

const add_guild_fields = require(ServerScriptService.player_data.schema.migrations.add_guild_fields)

export type rank_point = { time: number, rank: number }

export type with_player_profile_fields = add_guild_fields.with_guild_fields & {
	bio: string, -- filtered, rich text allowed
	last_online: number, -- unix seconds, bumped while the player is in a server
	rank_history: { rank_point },
}

const function add_player_profile_fields(data: add_guild_fields.with_guild_fields): with_player_profile_fields
	const new_data = table.clone(data) :: with_player_profile_fields
	new_data.bio = ""
	new_data.last_online = 0
	new_data.rank_history = {}
	return new_data
end

return add_player_profile_fields
