const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const PLAYER_PROFILE_DEFAULT_ASSETS = require(ReplicatedStorage.shared.player_profile.PLAYER_PROFILE_DEFAULT_ASSETS)
const PLAYER_PROFILE_LIMITS = require(ReplicatedStorage.shared.player_profile.PLAYER_PROFILE_LIMITS)
const create_player_summary = require(script.Parent.Parent.Parent.player_row.create_player_summary)
const format_date = require(script.Parent.Parent.Parent.format.format_date)
const format_number = require(script.Parent.Parent.Parent.format.format_number)
const format_stat_sections = require(script.Parent.Parent.Parent.format.format_stat_sections)
const format_time_ago = require(script.Parent.Parent.Parent.format.format_time_ago)
const menu_navigation = require(script.Parent.Parent.Parent.navigation.menu_navigation)
const player_profile_snapshot_types = require(ReplicatedStorage.shared.player_profile.player_profile_snapshot_types)
const player_profile_types = require(script.Parent.Parent.player_profile_types)
const profile_types = require(script.Parent.Parent.Parent.profile_card.profile_types)
const sum_mode_stats = require(script.Parent.Parent.Parent.format.sum_mode_stats)

const SECONDS_PER_HOUR = 3600
-- last_online is bumped on an interval, so anything this recent means they're in a server right now
const ONLINE_GRACE = PLAYER_PROFILE_LIMITS.LAST_ONLINE_INTERVAL * 2.5

const function format_last_online(snapshot: player_profile_snapshot_types.player_profile_snapshot): string
	-- the device clock can be off, the server's clock is what wrote last_online
	const now = math.floor(workspace:GetServerTimeNow())
	if Players:GetPlayerByUserId(snapshot.user_id) or now - snapshot.last_online < ONLINE_GRACE then
		return "Online now"
	end
	-- saves from before last_online existed
	if snapshot.last_online == 0 then
		return "A while ago"
	end
	return format_time_ago(snapshot.last_online, now)
end

const function create_guild_field(
	guild: player_profile_snapshot_types.profile_guild_snapshot?
): profile_types.info_field
	if guild == nil then
		return { id = "guild", label = "Current guild", value = "None" }
	end
	const function open_guild(): ()
		menu_navigation.open_guild(guild.id)
	end
	return { id = "guild", label = "Current guild", value = `[{guild.tag}] {guild.name}`, on_activated = open_guild }
end

-- turns what the server sent into what the profile menu shows
-- names come from user_info_cache, so rerender with use_user_info_version
const function format_player_profile_snapshot(
	snapshot: player_profile_snapshot_types.player_profile_snapshot
): player_profile_types.player_profile
	const summary = create_player_summary(snapshot.user_id, snapshot.banner)
	const rank_history: { profile_types.rank_point } = {}
	for _, point in snapshot.rank_history do
		table.insert(rank_history, { time = point.time, rank = point.rank })
	end
	return {
		user_id = snapshot.user_id,
		display_name = summary.display_name,
		username = summary.username,
		headshot = summary.headshot,
		banner = if snapshot.banner ~= "" then snapshot.banner else PLAYER_PROFILE_DEFAULT_ASSETS.banner,
		info_fields = {
			{ id = "first_joined", label = "First joined", value = format_date(snapshot.first_joined, true) },
			create_guild_field(snapshot.guild),
			{ id = "last_online", label = "Last online", value = format_last_online(snapshot) },
		},
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
				value = `{format_number(snapshot.playtime // SECONDS_PER_HOUR)}h`,
			},
			{
				id = "wins",
				icon = "🏆",
				label = "Wins",
				value = format_number(sum_mode_stats(snapshot.stats).wins),
				colour = COLOURS.yellow_200,
			},
		},
		rank_history = rank_history,
		bio = snapshot.bio,
		stat_sections = format_stat_sections(snapshot.stats, snapshot.playtime),
	}
end

return format_player_profile_snapshot
