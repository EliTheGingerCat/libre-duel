export type mode = "solo" | "duo"

const MODE_OPTIONS = {
	solo = {
		name = "Solo",
		description = "Play as a lone wolf!",
		icon = "rbxassetid://74540463397999",
		colour = Color3.new(139 / 255, 1, 247 / 255),
	},
	duo = {
		name = "Duos",
		description = "Play with a teammate!",
		icon = "rbxassetid://100734044686485",
		colour = Color3.new(1, 249 / 255, 169 / 255),
	},
}

return MODE_OPTIONS
