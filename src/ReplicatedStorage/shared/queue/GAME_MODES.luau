export type submode = "solo" | "duos"

-- The single source of truth for submodes, grouped the same way as saved stats and in the order they are shown to players.
const GAME_MODES: { bridge: { submode } } = {
	bridge = {
		"solo",
		"duos",
	},
}

return GAME_MODES
