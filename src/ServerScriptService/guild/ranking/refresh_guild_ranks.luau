const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const GUILD_LIMITS = require(ReplicatedStorage.shared.guild.GUILD_LIMITS)
const fetch_leaderboard_ranks = require(ServerScriptService.leaderboard.fetch_leaderboard_ranks)
const guild_leaderboard_store = require(script.Parent.guild_leaderboard_store)
const guild_rank_cache = require(script.Parent.guild_rank_cache)
const guild_session_refcount = require(ServerScriptService.guild.session.guild_session_refcount)
const player_guild_ids = require(ServerScriptService.guild.session.player_guild_ids)
const push_guild_state = require(ServerScriptService.guild.replication.push_guild_state)
const record_guild_rank_history = require(script.Parent.record_guild_rank_history)

-- yields, false when the leaderboard couldn't be read and the old ranks were kept
const function refresh_guild_ranks(): boolean
	const ranks = fetch_leaderboard_ranks(guild_leaderboard_store, GUILD_LIMITS.MAX_TRACKED_RANK)
	if ranks == nil then
		return false
	end
	table.clear(guild_rank_cache)
	for guild_id, rank in ranks do
		guild_rank_cache[guild_id] = rank
	end
	for _, guild_id in guild_session_refcount.get_active_guild_ids() do
		const rank = guild_rank_cache[guild_id]
		if rank then
			record_guild_rank_history(guild_id, rank)
		end
	end
	for player in player_guild_ids do
		push_guild_state(player)
	end
	return true
end

return refresh_guild_ranks
