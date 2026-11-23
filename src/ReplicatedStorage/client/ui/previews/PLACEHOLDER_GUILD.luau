const ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const MODE_DEFINITIONS = require(ReplicatedStorage.shared.modes.MODE_DEFINITIONS)
const PLACEHOLDER_ASSETS = require(script.Parent.PLACEHOLDER_ASSETS)
const PLACEHOLDER_STAT_GROUPS = require(script.Parent.PLACEHOLDER_STAT_GROUPS)
const create_placeholder_rank_history = require(script.Parent.create_placeholder_rank_history)
const guild_types = require(script.Parent.Parent.guild.guild_types)

const PLACEHOLDER_GUILD: guild_types.guild = {
	id = "00000000-0000-0000-0000-000000000000",
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
	stat_sections = {
		{
			id = "matches",
			title = "Matches",
			stats = {
				{ id = "games", label = "Games played", value = "314,985" },
				{ id = "wins", label = "Wins", value = "195,291" },
				{ id = "losses", label = "Losses", value = "119,694" },
				{ id = "win_rate", label = "Win rate", value = "62%" },
				{ id = "win_loss_ratio", label = "W/LR", value = "1.63" },
			},
		},
		{
			id = "combat",
			title = "Combat",
			stats = {
				{ id = "kills", label = "Kills", value = "412,870" },
				{ id = "deaths", label = "Deaths", value = "192,930" },
				{ id = "kill_death_ratio", label = "K/D", value = "2.14" },
				{ id = "goals", label = "Goals", value = "288,104" },
			},
		},
		{
			id = "playtime",
			title = "Playtime",
			stats = {
				{ id = "playtime", label = "Total", value = "5,704h" },
			},
		},
		{
			id = "bridge_solo",
			title = "Bridge solo",
			title_colour = MODE_DEFINITIONS[1].colour,
			stats = {
				{ id = "games", label = "Games played", value = "223,639" },
				{ id = "wins", label = "Wins", value = "143,129" },
				{ id = "losses", label = "Losses", value = "80,510" },
				{ id = "win_rate", label = "Win rate", value = "64%" },
				{ id = "win_loss_ratio", label = "W/LR", value = "1.78" },
				{ id = "kills", label = "Kills", value = "301,522" },
				{ id = "deaths", label = "Deaths", value = "130,529" },
				{ id = "kill_death_ratio", label = "K/D", value = "2.31" },
				{ id = "goals", label = "Goals", value = "214,870" },
			},
		},
		{
			id = "bridge_duos",
			title = "Bridge duos",
			title_colour = MODE_DEFINITIONS[2].colour,
			stats = {
				{ id = "games", label = "Games played", value = "91,346" },
				{ id = "wins", label = "Wins", value = "52,162" },
				{ id = "losses", label = "Losses", value = "39,184" },
				{ id = "win_rate", label = "Win rate", value = "57%" },
				{ id = "win_loss_ratio", label = "W/LR", value = "1.33" },
				{ id = "kills", label = "Kills", value = "111,348" },
				{ id = "deaths", label = "Deaths", value = "62,401" },
				{ id = "kill_death_ratio", label = "K/D", value = "1.78" },
				{ id = "goals", label = "Goals", value = "73,234" },
			},
		},
	},
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
	banned = {
		{
			user_id = 3,
			display_name = "NOT miau",
			username = "breter98",
			headshot = PLACEHOLDER_ASSETS.headshot,
			banner = PLACEHOLDER_ASSETS.member_banner,
			banned = "Nov 21, 2026",
		},
	},
}

return PLACEHOLDER_GUILD
