const ServerScriptService = game:GetService("ServerScriptService")

const guild_schema = require(ServerScriptService.guild.data.schema.guild_schema)

-- the one place that decides what guilds are ranked by, swap this for levels once they exist
-- OrderedDataStore only stores integers
const function get_guild_score(data: guild_schema.guild_data): number
	local wins = 0
	for _, mode_stats in data.totals do
		wins += mode_stats.wins
	end
	return math.floor(wins)
end

return get_guild_score
