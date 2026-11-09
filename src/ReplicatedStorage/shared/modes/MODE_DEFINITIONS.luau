export type mode_id = "bridge_solo" | "bridge_duos"
export type definition = {
	id: mode_id,
	game: "bridge",
	submode: "solo" | "duos",
	teams: number,
	entities_per_team: number,
	name: string,
	description: string,
	icon: string,
	colour: Color3,
}

-- The single source of truth for modes, in the order they are shown to players.
-- game and submode match the keys in saved stats.
const MODE_DEFINITIONS: { definition } = {
	{
		id = "bridge_solo",
		game = "bridge",
		submode = "solo",
		teams = 2,
		entities_per_team = 1,
		name = "Solo",
		description = "Play as a lone wolf!",
		icon = "rbxassetid://74540463397999",
		colour = Color3.new(139 / 255, 1, 247 / 255),
	},
	{
		id = "bridge_duos",
		game = "bridge",
		submode = "duos",
		teams = 2,
		entities_per_team = 2,
		name = "Duos",
		description = "Play with a teammate!",
		icon = "rbxassetid://100734044686485",
		colour = Color3.new(1, 249 / 255, 169 / 255),
	},
}

return MODE_DEFINITIONS
