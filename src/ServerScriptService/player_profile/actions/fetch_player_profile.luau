const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const normalize_mode_stats = require(ServerScriptService.guild.data.normalize_mode_stats)
const player_profile_snapshot_types = require(ReplicatedStorage.shared.player_profile.player_profile_snapshot_types)
const player_rank_cache = require(ServerScriptService.player_ranking.player_rank_cache)
const read_guild_data = require(ServerScriptService.guild.data.read_guild_data)
const read_player_data = require(ServerScriptService.player_data.read_player_data)
const server_join_times = require(ServerScriptService.playtime_logging.server_join_times)

-- the guild hint in player data can be stale, so the guild's own member list decides
const function read_profile_guild(
	user_id: number,
	guild_id: string
): player_profile_snapshot_types.profile_guild_snapshot?
	if guild_id == "" then
		return nil
	end
	const data = read_guild_data(guild_id)
	if data == nil or data.members[tostring(user_id)] == nil then
		return nil
	end
	return { id = data.id, name = data.name, tag = data.tag }
end

-- yields when the player isn't in this server, nil when they never played or the read failed
const function fetch_player_profile(user_id: number): player_profile_snapshot_types.player_profile_snapshot?
	const data = read_player_data(user_id)
	if data == nil or data.first_joined == 0 then
		return nil
	end
	-- playtime is only saved when a session ends, so the running session is added for players in this server
	local playtime = data.playtime or 0
	const player_in_server = Players:GetPlayerByUserId(user_id)
	const join_time = if player_in_server then server_join_times[player_in_server] else nil
	if join_time then
		playtime += os.time() - join_time
	end
	-- saves that never went through a session can be missing migrated fields
	return {
		user_id = user_id,
		first_joined = data.first_joined,
		last_online = if player_in_server then os.time() else data.last_online or 0,
		banner = data.player_banner_id or "",
		bio = data.bio or "",
		playtime = playtime,
		-- zap errors on modes that no longer exist and on missing stats, so it gets normalized
		stats = normalize_mode_stats(data.stats),
		rank = player_rank_cache[tostring(user_id)],
		rank_history = data.rank_history or {},
		guild = read_profile_guild(user_id, data.guild_id or ""),
	}
end

return fetch_player_profile
