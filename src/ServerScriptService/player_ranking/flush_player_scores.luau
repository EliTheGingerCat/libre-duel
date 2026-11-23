const Players = game:GetService("Players")
const ServerScriptService = game:GetService("ServerScriptService")

const get_cached_player_data = require(ServerScriptService.player_data.get_cached_player_data)
const get_player_score = require(script.Parent.get_player_score)
const last_saved_player_scores = require(script.Parent.last_saved_player_scores)
const player_leaderboard_store = require(script.Parent.player_leaderboard_store)
const player_rank_cache = require(script.Parent.player_rank_cache)

-- saves the score of everyone in this server whose score changed since the last flush
-- players without a single point stay off the leaderboard
-- returns true when a player that had no rank yet was saved, so the caller can reread ranks early
const function flush_player_scores(): boolean
	local saved_unranked_player = false
	for _, player in Players:GetPlayers() do
		const data = get_cached_player_data(player)
		if data then
			const score = get_player_score(data)
			if score > 0 and last_saved_player_scores[player] ~= score then
				const key = tostring(player.UserId)
				const ok, message = pcall(player_leaderboard_store.SetAsync, player_leaderboard_store, key, score)
				if not ok then
					warn(`Could not save player score: {message}`)
				else
					last_saved_player_scores[player] = score
					if player_rank_cache[key] == nil then
						saved_unranked_player = true
					end
				end
			end
		end
	end
	return saved_unranked_player
end

return flush_player_scores
