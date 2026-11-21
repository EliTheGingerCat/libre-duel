const ReplicatedStorage = game:GetService("ReplicatedStorage")

const COLOURS = require(ReplicatedStorage.shared.ui.COLOURS)
const PLACEHOLDER_ASSETS = require(script.Parent.PLACEHOLDER_ASSETS)
const PLACEHOLDER_STAT_GROUPS = require(script.Parent.PLACEHOLDER_STAT_GROUPS)
const create_placeholder_rank_history = require(script.Parent.create_placeholder_rank_history)
const player_profile_types = require(script.Parent.Parent.player_profile.player_profile_types)

const PLACEHOLDER_PLAYER_PROFILE: player_profile_types.player_profile = {
	display_name = "miau",
	username = "breter98",
	headshot = PLACEHOLDER_ASSETS.headshot,
	banner = PLACEHOLDER_ASSETS.profile_banner,
	info_fields = {
		{ id = "joined", label = "Joined", value = "November 21, 2026" },
		{ id = "guild", label = "Guild", value = "[TOA] The Ok Association" },
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
	stats = PLACEHOLDER_STAT_GROUPS,
}

return PLACEHOLDER_PLAYER_PROFILE
