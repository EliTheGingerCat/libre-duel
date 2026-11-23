const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const PLAYER_PROFILE_LIMITS = require(ReplicatedStorage.shared.player_profile.PLAYER_PROFILE_LIMITS)
const fetch_leaderboard_ranks = require(ServerScriptService.leaderboard.fetch_leaderboard_ranks)
const get_cached_player_data = require(ServerScriptService.player_data.get_cached_player_data)
const player_leaderboard_store = require(script.Parent.player_leaderboard_store)
const player_rank_cache = require(script.Parent.player_rank_cache)
const record_player_rank_history = require(script.Parent.record_player_rank_history)

-- yields, false when the leaderboard couldn't be read and the old ranks were kept
const function refresh_player_ranks(): boolean
	const ranks = fetch_leaderboard_ranks(player_leaderboard_store, PLAYER_PROFILE_LIMITS.MAX_TRACKED_RANK)
	if ranks == nil then
		return false
	end
	table.clear(player_rank_cache)
	for key, rank in ranks do
		player_rank_cache[key] = rank
	end
	for _, player in Players:GetPlayers() do
		const rank = player_rank_cache[tostring(player.UserId)]
		if rank and get_cached_player_data(player) then
			record_player_rank_history(player, rank)
		end
	end
	return true
end

return refresh_player_ranks
