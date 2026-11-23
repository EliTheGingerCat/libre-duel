const ServerScriptService = game:GetService("ServerScriptService")

const player_schema = require(ServerScriptService.player_data.schema.player_schema)

-- the one place that decides what players are ranked by, swap this for levels once they exist
-- bump the store name in player_leaderboard_store at the same time, since old scores mean something else
-- OrderedDataStore only stores integers
const function get_player_score(data: player_schema.player_data): number
	local wins = 0
	for _, mode_stats in data.stats do
		wins += mode_stats.wins
	end
	return math.floor(wins)
end

return get_player_score
