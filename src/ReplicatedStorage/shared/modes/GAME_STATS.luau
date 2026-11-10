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
export type modes = { [mode]: stats }

const DEFAULT_STATS: stats = { wins = 0, goals = 0, kills = 0, losses = 0, deaths = 0 }

-- The default stats for each mode in MODE_DEFINITIONS.
const GAME_STATS: modes = {}
for _, definition in MODE_DEFINITIONS do
	GAME_STATS[definition.id] = table.clone(DEFAULT_STATS)
end

return GAME_STATS
