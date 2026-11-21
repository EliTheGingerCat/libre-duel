const ReplicatedStorage = game:GetService("ReplicatedStorage")
const ServerScriptService = game:GetService("ServerScriptService")

const guild_rank_cache = require(ServerScriptService.guild.ranking.guild_rank_cache)
const guild_schema = require(ServerScriptService.guild.data.schema.guild_schema)
const guild_snapshot_types = require(ReplicatedStorage.shared.guild.guild_snapshot_types)
const normalize_mode_stats = require(ServerScriptService.guild.data.normalize_mode_stats)

const function compare_members(
	first: guild_snapshot_types.member_snapshot,
	second: guild_snapshot_types.member_snapshot
): boolean
	return first.joined < second.joined
end

const function compare_banned(
	first: guild_snapshot_types.banned_snapshot,
	second: guild_snapshot_types.banned_snapshot
): boolean
	return first.banned_at > second.banned_at
end

const function compare_invites(
	first: guild_snapshot_types.outgoing_invite_snapshot,
	second: guild_snapshot_types.outgoing_invite_snapshot
): boolean
	return first.invited_at > second.invited_at
end

-- include_private adds the ban list and outgoing invites, which only members get to see
const function build_guild_snapshot(
	data: guild_schema.guild_data,
	include_private: boolean
): guild_snapshot_types.guild_snapshot
	const members = {}
	for user_id, member in data.members do
		table.insert(members, {
			user_id = tonumber(user_id) :: number,
			joined = member.joined,
			banner = member.banner,
			playtime = member.playtime,
			stats = normalize_mode_stats(member.stats),
		})
	end
	table.sort(members, compare_members)

	const banned = {}
	const outgoing_invites = {}
	if include_private then
		for user_id, banned_at in data.banned do
			table.insert(banned, { user_id = tonumber(user_id) :: number, banned_at = banned_at })
		end
		for user_id, invited_at in data.outgoing_invites do
			table.insert(outgoing_invites, { user_id = tonumber(user_id) :: number, invited_at = invited_at })
		end
		table.sort(banned, compare_banned)
		table.sort(outgoing_invites, compare_invites)
	end

	const rank_history = {}
	for _, point in data.rank_history do
		table.insert(rank_history, { time = point.time, rank = point.rank })
	end

	return {
		id = data.id,
		owner_id = data.owner_id,
		created = data.created,
		name = data.name,
		tag = data.tag,
		description = data.description,
		icon = data.icon,
		banner = data.banner,
		discord_invite = data.discord_invite,
		members = members,
		banned = banned,
		outgoing_invites = outgoing_invites,
		totals = normalize_mode_stats(data.totals),
		total_playtime = data.total_playtime,
		rank = guild_rank_cache[data.id],
		rank_history = rank_history,
	}
end

return build_guild_snapshot
