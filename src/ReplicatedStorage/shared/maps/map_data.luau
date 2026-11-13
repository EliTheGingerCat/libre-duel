export type team_data = {
	CAGE: Instance,
	GOAL: BasePart,
	SPAWN: BasePart,
}

export type map_data = {
	MAP_NAME: string,
	MAP_DESCRIPTION: string,
	MAP_ICON: number,
	MAP_AUTHORS: { string },
	BRIDGE: BasePart,
	TEAM1: team_data,
	TEAM2: team_data,
}

return {}
