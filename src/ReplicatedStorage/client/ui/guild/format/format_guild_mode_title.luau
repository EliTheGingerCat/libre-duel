const ReplicatedStorage = game:GetService("ReplicatedStorage")

const MODE_DEFINITIONS = require(ReplicatedStorage.shared.modes.MODE_DEFINITIONS)

-- "Bridge solo"
const function format_guild_mode_title(definition: MODE_DEFINITIONS.definition): string
	const game_name: string = definition.game
	return `{string.upper(string.sub(game_name, 1, 1))}{string.sub(game_name, 2)} {string.lower(definition.name)}`
end

return format_guild_mode_title
