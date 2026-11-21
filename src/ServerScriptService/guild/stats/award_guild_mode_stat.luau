const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const GAME_STATS = require(ReplicatedStorage.shared.modes.GAME_STATS)
const dirty_guild_scores = require(ServerScriptService.guild.ranking.dirty_guild_scores)
const drop = require(ServerScriptService.ServerPackages.drop)
const guild_schema = require(ServerScriptService.guild.data.schema.guild_schema)
const guild_session_refcount = require(ServerScriptService.guild.session.guild_session_refcount)
const guild_store = require(ServerScriptService.guild.data.guild_store)
const normalize_mode_stats = require(ServerScriptService.guild.data.normalize_mode_stats)
const player_guild_ids = require(ServerScriptService.guild.session.player_guild_ids)

-- adds to the member's own stats and the guild totals, does nothing for players without a guild
-- queued through the session so a burst of kills becomes one datastore write
const function award_guild_mode_stat(player: Player, mode: GAME_STATS.mode, stat: GAME_STATS.stat, amount: number): ()
	const guild_id = player_guild_ids[player]
	if guild_id == nil or not guild_session_refcount.is_active(guild_id) then
		return
	end
	const user_id = tostring(player.UserId)
	const function add_to_stat(data: guild_schema.guild_data): guild_schema.guild_data
		const member = data.members[user_id]
		if member == nil then
			return data
		end
		const new_data = table.clone(data)
		const new_members = table.clone(data.members)
		const new_member = table.clone(member)
		const member_stats = normalize_mode_stats(member.stats)
		member_stats[mode][stat] += amount
		new_member.stats = member_stats
		new_members[user_id] = new_member
		new_data.members = new_members
		const totals = normalize_mode_stats(data.totals)
		totals[mode][stat] += amount
		new_data.totals = totals
		return new_data
	end
	drop.update(guild_store, guild_id, add_to_stat)
	dirty_guild_scores[guild_id] = true
end

return award_guild_mode_stat
