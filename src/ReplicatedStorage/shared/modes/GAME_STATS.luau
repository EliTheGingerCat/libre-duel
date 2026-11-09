-- The stats tracked for each game, keyed by the game field in MODE_DEFINITIONS and shared by all of its submodes.
const GAME_STATS: { [string]: { string } } = {
	bridge = { "wins", "goals", "kills", "losses", "deaths" },
}

return GAME_STATS
