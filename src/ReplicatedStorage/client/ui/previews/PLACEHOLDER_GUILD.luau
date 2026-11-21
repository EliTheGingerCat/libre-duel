const ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const PLACEHOLDER_ASSETS = require(script.Parent.PLACEHOLDER_ASSETS)
const PLACEHOLDER_STAT_GROUPS = require(script.Parent.PLACEHOLDER_STAT_GROUPS)
const create_placeholder_rank_history = require(script.Parent.create_placeholder_rank_history)
const guild_types = require(script.Parent.Parent.guild.guild_types)

const PLACEHOLDER_GUILD: guild_types.guild = {
	name = "The Ok Association",
	tag = "TOA",
	icon = PLACEHOLDER_ASSETS.headshot,
	banner = PLACEHOLDER_ASSETS.profile_banner,
	info_fields = {
		{ id = "created", label = "Created", value = "November 21, 2026" },
		{ id = "discord_invite", label = "Discord invite", value = "discord.gg/bridgeduel" },
		{ id = "owner", label = "Owner", value = "@breter98" },
	},
	highlight_stats = {
		{ id = "rank", label = "Rank", value = "#3", colour = COLOURS.emerald_300 },
		{ id = "playtime", icon = "🕔", label = "Playtime", value = "5704h" },
		{ id = "wins", icon = "🏆", label = "Wins", value = "195291", colour = COLOURS.yellow_200 },
	},
	rank_history = create_placeholder_rank_history({
		12,
		12,
		11,
		11,
		9,
		10,
		9,
		8,
		8,
		7,
		7,
		8,
		6,
		6,
		5,
		5,
		6,
		5,
		4,
		4,
		5,
		4,
		4,
		3,
		4,
		3,
		3,
		3,
		4,
		3,
	}),
	about = "Welcome to TOA guild!\n<font color='rgb(255, 84, 84)'>Rich text</font> works here too.\n<b>Pretty cool</b>, right?",
	members = {
		{
			user_id = 1,
			display_name = "NOT miau",
			username = "breter98",
			headshot = PLACEHOLDER_ASSETS.headshot,
			banner = PLACEHOLDER_ASSETS.member_banner,
			joined = "Nov 21, 2026",
			is_owner = true,
			stats = PLACEHOLDER_STAT_GROUPS,
		},
		{
			user_id = 2,
			display_name = "NOT miau",
			username = "breter98",
			headshot = PLACEHOLDER_ASSETS.headshot,
			banner = PLACEHOLDER_ASSETS.member_banner,
			joined = "Nov 21, 2026",
			is_owner = false,
			stats = PLACEHOLDER_STAT_GROUPS,
		},
	},
}

return PLACEHOLDER_GUILD
