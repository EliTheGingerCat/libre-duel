const ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const PLACEHOLDER_ASSETS = require(script.Parent.PLACEHOLDER_ASSETS)
const create_placeholder_rank_history = require(script.Parent.create_placeholder_rank_history)
const format_stat_sections = require(script.Parent.Parent.format.format_stat_sections)
const menu_navigation = require(script.Parent.Parent.navigation.menu_navigation)
const player_profile_types = require(script.Parent.Parent.player_profile.player_profile_types)

const PLACEHOLDER_PLAYTIME = 530 * 3600
const PLACEHOLDER_MODE_STATS = {
	bridge_solo = { wins = 2100, goals = 6400, kills = 15200, losses = 1400, deaths = 11800 },
	bridge_duos = { wins = 882, goals = 2100, kills = 6100, losses = 700, deaths = 5200 },
}

const function open_placeholder_guild(): ()
	menu_navigation.open_guild("00000000-0000-0000-0000-000000000000")
end

const PLACEHOLDER_PLAYER_PROFILE: player_profile_types.player_profile = {
	user_id = 1,
	display_name = "miau",
	username = "breter98",
	headshot = PLACEHOLDER_ASSETS.headshot,
	banner = PLACEHOLDER_ASSETS.profile_banner,
	info_fields = {
		{ id = "first_joined", label = "First joined", value = "November 21, 2026" },
		{
			id = "guild",
			label = "Current guild",
			value = "[TOA] The Ok Association",
			on_activated = open_placeholder_guild,
		},
		{ id = "last_online", label = "Last online", value = "5 minutes ago" },
	},
	highlight_stats = {
		{ id = "rank", label = "Rank", value = "#41", colour = COLOURS.emerald_300 },
		{ id = "playtime", icon = "🕔", label = "Playtime", value = "530h" },
		{ id = "wins", icon = "🏆", label = "Wins", value = "2982", colour = COLOURS.yellow_200 },
	},
	rank_history = create_placeholder_rank_history({
		88,
		85,
		86,
		80,
		74,
		77,
		70,
		66,
		69,
		63,
		60,
		61,
		58,
		55,
		57,
		52,
		50,
		53,
		49,
		47,
		48,
		45,
		46,
		44,
		42,
		43,
		41,
		44,
		42,
		41,
	}),
	bio = "Hey, i'm breter98! So nice to see you.\n<font color='rgb(255, 84, 84)'>Rich text</font> works here too.\n<b>Pretty cool</b>, right?",
	stat_sections = format_stat_sections(PLACEHOLDER_MODE_STATS, PLACEHOLDER_PLAYTIME),
}

return PLACEHOLDER_PLAYER_PROFILE
