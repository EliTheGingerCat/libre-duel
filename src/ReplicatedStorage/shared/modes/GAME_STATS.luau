const MODE_DEFINITIONS = require(script.Parent.MODE_DEFINITIONS)

export type mode = MODE_DEFINITIONS.mode_id
export type stat = "wins" | "goals" | "kills" | "losses" | "deaths"
export type stats = {
	wins: number,
	goals: number,
	kills: number,
	losses: number,
	deaths: number,
}
export type modes = {
	bridge_solo: stats,
	bridge_duos: stats,
}

const DEFAULT_STATS: stats = { wins = 0, goals = 0, kills = 0, losses = 0, deaths = 0 }

-- The default stats for each mode, keyed by the id in MODE_DEFINITIONS.
const GAME_STATS: modes = {
	bridge_solo = DEFAULT_STATS,
	bridge_duos = DEFAULT_STATS,
}

return GAME_STATS
