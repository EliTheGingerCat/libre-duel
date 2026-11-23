const ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const GUILD_DEFAULT_ASSETS = require(ReplicatedStorage.shared.guild.GUILD_DEFAULT_ASSETS)
const GUILD_LIMITS = require(ReplicatedStorage.shared.guild.GUILD_LIMITS)
const create_player_summary = require(script.Parent.Parent.Parent.player_row.create_player_summary)
const format_date = require(script.Parent.Parent.Parent.format.format_date)
const format_mode_stat_groups = require(script.Parent.Parent.Parent.format.format_mode_stat_groups)
const format_number = require(script.Parent.Parent.Parent.format.format_number)
const format_stat_sections = require(script.Parent.Parent.Parent.format.format_stat_sections)
const guild_snapshot_types = require(ReplicatedStorage.shared.guild.guild_snapshot_types)
const guild_types = require(script.Parent.Parent.guild_types)
const menu_navigation = require(script.Parent.Parent.Parent.navigation.menu_navigation)
const profile_types = require(script.Parent.Parent.Parent.profile_card.profile_types)
const sum_mode_stats = require(script.Parent.Parent.Parent.format.sum_mode_stats)
const user_info_cache = require(ReplicatedStorage.client.guild.user_info_cache)

const SECONDS_PER_HOUR = 3600

-- turns what the server sent into what the guild menu shows
-- show_discord has to come from can_see_discord_links, Roblox policy decides who may see it
const function format_guild_snapshot(
	snapshot: guild_snapshot_types.guild_snapshot,
	show_discord: boolean
): guild_types.guild
	const user_ids = { snapshot.owner_id }
	for _, member in snapshot.members do
		table.insert(user_ids, member.user_id)
	end
	for _, banned in snapshot.banned do
		table.insert(user_ids, banned.user_id)
	end
	user_info_cache.request(user_ids)

	const members: { guild_types.member } = {}
	for _, member_snapshot in snapshot.members do
		const member = create_player_summary(member_snapshot.user_id, member_snapshot.banner) :: guild_types.member
		member.joined = format_date(member_snapshot.joined)
		member.is_owner = member_snapshot.user_id == snapshot.owner_id
		member.stats = format_mode_stat_groups(member_snapshot.stats, member_snapshot.playtime)
		table.insert(members, member)
	end

	const banned: { guild_types.banned_member } = {}
	for _, banned_snapshot in snapshot.banned do
		const banned_member = create_player_summary(banned_snapshot.user_id, "") :: guild_types.banned_member
		banned_member.banned = format_date(banned_snapshot.banned_at)
		table.insert(banned, banned_member)
	end

	const owner_info = user_info_cache.get(snapshot.owner_id)
	const function open_owner_profile(): ()
		menu_navigation.open_player_profile(snapshot.owner_id)
	end
	const info_fields: { profile_types.info_field } = {
		{ id = "created", label = "Created", value = format_date(snapshot.created, true) },
		{
			id = "owner",
			label = "Owner",
			value = `@{if owner_info then owner_info.username else snapshot.owner_id}`,
			on_activated = open_owner_profile,
		},
		{ id = "members", label = "Members", value = `{#snapshot.members}/{GUILD_LIMITS.MAX_MEMBERS}` },
	}
	if show_discord and snapshot.discord_invite ~= "" then
		table.insert(
			info_fields,
			2,
			{ id = "discord_invite", label = "Discord invite", value = snapshot.discord_invite }
		)
	end

	const rank_history: { profile_types.rank_point } = {}
	for _, point in snapshot.rank_history do
		table.insert(rank_history, { time = point.time, rank = point.rank })
	end

	return {
		id = snapshot.id,
		name = snapshot.name,
		tag = snapshot.tag,
		icon = if snapshot.icon ~= "" then snapshot.icon else GUILD_DEFAULT_ASSETS.icon,
		banner = if snapshot.banner ~= "" then snapshot.banner else GUILD_DEFAULT_ASSETS.banner,
		info_fields = info_fields,
		highlight_stats = {
			{
				id = "rank",
				label = "Rank",
				value = if snapshot.rank then `#{snapshot.rank}` else "Unranked",
				colour = COLOURS.emerald_300,
			},
			{
				id = "playtime",
				icon = "🕔",
				label = "Playtime",
				value = `{format_number(snapshot.total_playtime // SECONDS_PER_HOUR)}h`,
			},
			{
				id = "wins",
				icon = "🏆",
				label = "Wins",
				value = format_number(sum_mode_stats(snapshot.totals).wins),
				colour = COLOURS.yellow_200,
			},
		},
		rank_history = rank_history,
		stat_sections = format_stat_sections(snapshot.totals, snapshot.total_playtime),
		about = snapshot.description,
		members = members,
		banned = banned,
	}
end

return format_guild_snapshot
