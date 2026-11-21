const profile_types = require(script.Parent.Parent.profile_card.profile_types)

const PLACEHOLDER_STAT_GROUPS: { profile_types.stat_group } = {
	{
		id = "overall",
		title = "Overall",
		stats = {
			{ id = "playtime", icon = "🕔", label = "Playtime", value = "530 hours" },
			{ id = "total_clicks", icon = "🖱️", label = "Total clicks", value = "194,673" },
			{ id = "level", icon = "⭐", label = "Level", value = "[PLACEHOLDER]" },
			{ id = "win_loss_ratio", icon = "➗", label = "W/LR", value = "1" },
		},
	},
	{
		id = "bridge_solo",
		title = "Bridge solo",
		stats = {
			{ id = "wins", icon = "🏆", label = "Wins", value = "1,491" },
			{ id = "kills", icon = "⚔️", label = "Kills", value = "1,491" },
			{ id = "losses", icon = "💀", label = "Losses", value = "1,491" },
			{ id = "win_loss_ratio", icon = "➗", label = "W/LR", value = "1" },
		},
	},
	{
		id = "bridge_duo",
		title = "Bridge duo",
		stats = {
			{ id = "wins", icon = "🏆", label = "Wins", value = "1,491" },
			{ id = "kills", icon = "⚔️", label = "Kills", value = "1,491" },
			{ id = "losses", icon = "💀", label = "Losses", value = "1,491" },
			{ id = "win_loss_ratio", icon = "➗", label = "W/LR", value = "1" },
		},
	},
}

return PLACEHOLDER_STAT_GROUPS
